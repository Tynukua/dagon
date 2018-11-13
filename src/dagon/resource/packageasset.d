/*
Copyright (c) 2018 Timur Gafarov

Boost Software License - Version 1.0 - August 17th, 2003
Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dagon.resource.packageasset;

import std.stdio;
import std.string;
import std.format;
import std.path;

import dlib.core.memory;
import dlib.core.stream;
import dlib.filesystem.filesystem;
import dlib.filesystem.stdfs;
import dlib.container.array;
import dlib.container.dict;
import dlib.math.vector;
import dlib.math.quaternion;
import dlib.image.color;

import dagon.core.ownership;
import dagon.core.interfaces;
import dagon.resource.asset;
import dagon.resource.boxfs;
import dagon.resource.obj;
import dagon.resource.textureasset;
import dagon.resource.entityasset;
import dagon.resource.materialasset;
import dagon.resource.scene;
import dagon.resource.props;
import dagon.graphics.mesh;
import dagon.graphics.texture;
import dagon.graphics.material;
import dagon.logics.entity;

/*
 * A simple asset package format based on Box container (https://github.com/gecko0307/box).
 * It is an archive that stores entities, meshes, materials and textures.
 */

class PackageAssetOwner: Owner
{
    this(Owner o)
    {
        super(o);
    }
}

class PackageAsset: Asset
{
    Dict!(OBJAsset, string) meshes;
    Dict!(EntityAsset, string) entities;
    Dict!(TextureAsset, string) textures;
    Dict!(MaterialAsset, string) materials;

    string filename;
    string index;
    BoxFileSystem boxfs;
    AssetManager assetManager;
    Scene scene;
    Entity rootEntity;
    PackageAssetOwner assetOwner;

    this(Scene scene, Owner o)
    {
        super(o);
        this.scene = scene;

        rootEntity = New!Entity(scene.eventManager, this);
    }

    ~this()
    {
        release();
    }

    override bool loadThreadSafePart(string filename, InputStream istrm, ReadOnlyFileSystem fs, AssetManager mngr)
    {
        this.filename = filename;
        meshes = New!(Dict!(OBJAsset, string))();
        entities = New!(Dict!(EntityAsset, string))();
        textures = New!(Dict!(TextureAsset, string))();
        materials = New!(Dict!(MaterialAsset, string))();
        boxfs = New!BoxFileSystem(fs, filename);

        if (fileExists("INDEX"))
        {
            auto fstrm = boxfs.openForInput("INDEX");
            index = readText(fstrm);
            Delete(fstrm);
        }

        assetManager = mngr;

        assetOwner = New!PackageAssetOwner(null);

        return true;
    }

    override bool loadThreadUnsafePart()
    {
        return true;
    }

    bool loadAsset(Asset asset, string filename)
    {
        if (!fileExists(filename))
        {
            writefln("Error: cannot find file \"%s\" in package", filename);
            return false;
        }

        auto fstrm = boxfs.openForInput(filename);
        bool res = asset.loadThreadSafePart(filename, fstrm, boxfs, assetManager);
        asset.threadSafePartLoaded = res;
        Delete(fstrm);

        if (!res)
        {
            writefln("Error: failed to load asset \"%s\" from package", filename);
            return false;
        }
        else
        {
            res = asset.loadThreadUnsafePart();
            asset.threadUnsafePartLoaded = res;
            if (!res)
            {
                writefln("Error: failed to load asset \"%s\" from package", filename);
                return false;
            }
            else
            {
                return true;
            }
        }
    }

    Mesh mesh(string filename)
    {
        if (!(filename in meshes))
        {
            OBJAsset objAsset = New!OBJAsset(assetOwner);
            if (loadAsset(objAsset, filename))
            {
                meshes[filename] = objAsset;
                return objAsset.mesh;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return meshes[filename].mesh;
        }
    }

    Entity entity(string filename)
    {
        if (!(filename in entities))
        {
            EntityAsset entityAsset = New!EntityAsset(assetOwner);

            if (loadAsset(entityAsset, filename))
            {
                entities[filename] = entityAsset;

                Entity parent = rootEntity;

                if ("parent" in entityAsset.props)
                {
                    parent = entity(entityAsset.props.parent.toString);
                }

                entityAsset.entity = New!Entity(parent, assetOwner);
                entityAsset.entity.visible = true;
                entityAsset.entity.castShadow = true;
                entityAsset.entity.useMotionBlur = true;
                entityAsset.entity.layer = 1;
                entityAsset.entity.solid = true;
                entityAsset.entity.material = scene.defaultMaterial3D;

                if ("position" in entityAsset.props)
                {
                    entityAsset.entity.position = entityAsset.props.position.toVector3f;
                }

                if ("rotation" in entityAsset.props)
                {
                    entityAsset.entity.rotation = Quaternionf(entityAsset.props.rotation.toVector4f).normalized;
                }

                if ("scale" in entityAsset.props)
                {
                    entityAsset.entity.scaling = entityAsset.props.scale.toVector3f;
                }

                entityAsset.entity.updateTransformation();

                if ("visible" in entityAsset.props)
                {
                    entityAsset.entity.visible = entityAsset.props.visible.toBool;
                }

                if ("castShadow" in entityAsset.props)
                {
                    entityAsset.entity.castShadow = entityAsset.props.castShadow.toBool;
                }

                if ("useMotionBlur" in entityAsset.props)
                {
                    entityAsset.entity.useMotionBlur = entityAsset.props.useMotionBlur.toBool;
                }

                if ("solid" in entityAsset.props)
                {
                    entityAsset.entity.solid = entityAsset.props.solid.toBool;
                }

                if ("layer" in entityAsset.props)
                {
                    entityAsset.entity.layer = entityAsset.props.layer.toInt;
                }

                if ("mesh" in entityAsset.props)
                {
                    entityAsset.entity.drawable = mesh(entityAsset.props.mesh.toString);
                }

                if ("material" in entityAsset.props)
                {
                    entityAsset.entity.material = material(entityAsset.props.material.toString);
                }

                if (entityAsset.entity.parent)
                    scene.sortEntities(entityAsset.entity.parent.children);

                return entityAsset.entity;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return entities[filename].entity;
        }
    }

    Texture texture(string filename)
    {
        if (!(filename in textures))
        {
            TextureAsset texAsset = New!TextureAsset(assetManager.imageFactory, assetManager.hdrImageFactory, assetOwner);
            if (loadAsset(texAsset, filename))
            {
                textures[filename] = texAsset;
                return texAsset.texture;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return textures[filename].texture;
        }
    }

    Material material(string filename)
    {
        if (!(filename in materials))
        {
            MaterialAsset matAsset = New!MaterialAsset(assetOwner);
            if (loadAsset(matAsset, filename))
            {
                materials[filename] = matAsset;
                matAsset.material = createMaterial();

                // diffuse
                if ("diffuse" in matAsset.props)
                {
                    if (matAsset.props.diffuse.type == DPropType.String)
                    {
                        matAsset.material.diffuse = texture(matAsset.props.diffuse.toString);
                    }
                    else
                    {
                        Vector3f diffCol = matAsset.props.diffuse.toVector3f;
                        matAsset.material.diffuse = Color4f(diffCol.r, diffCol.g, diffCol.b, 1.0f);
                    }
                }

                // emission
                if ("emission" in matAsset.props)
                {
                    if (matAsset.props.emission.type == DPropType.String)
                    {
                        matAsset.material.emission = texture(matAsset.props.emission.toString);
                    }
                    else
                    {
                        Vector3f emissionCol = matAsset.props.emission.toVector3f;
                        matAsset.material.emission = Color4f(emissionCol.r, emissionCol.g, emissionCol.b, 1.0f);
                    }
                }

                // energy
                if ("energy" in matAsset.props)
                {
                    matAsset.material.energy = matAsset.props.energy.toFloat;
                }

                // normal
                if ("normal" in matAsset.props)
                {
                    if (matAsset.props.normal.type == DPropType.String)
                    {
                        matAsset.material.normal = texture(matAsset.props.normal.toString);
                    }
                }

                // height
                if ("height" in matAsset.props)
                {
                    if (matAsset.props.height.type == DPropType.String)
                    {
                        matAsset.material.height = texture(matAsset.props.height.toString);
                    }
                }

                // roughness
                if ("roughness" in matAsset.props)
                {
                    if (matAsset.props.roughness.type == DPropType.String)
                    {
                        matAsset.material.roughness = texture(matAsset.props.roughness.toString);
                    }
                    else
                    {
                        matAsset.material.roughness = matAsset.props.roughness.toFloat;
                    }
                }

                // metallic
                if ("metallic" in matAsset.props)
                {
                    if (matAsset.props.metallic.type == DPropType.String)
                    {
                        matAsset.material.metallic = texture(matAsset.props.metallic.toString);
                    }
                    else
                    {
                        matAsset.material.metallic = matAsset.props.metallic.toFloat;
                    }
                }

                // parallax
                if ("parallax" in matAsset.props)
                {
                    matAsset.material.parallax = matAsset.props.parallax.toInt;
                }

                // parallaxScale
                if ("parallaxScale" in matAsset.props)
                {
                    matAsset.material.parallaxScale = matAsset.props.parallaxScale.toFloat;
                }

                // parallaxBias
                if ("parallaxBias" in matAsset.props)
                {
                    matAsset.material.parallaxBias = matAsset.props.parallaxBias.toFloat;
                }

                // shadeless
                if ("shadeless" in matAsset.props)
                {
                    matAsset.material.shadeless = matAsset.props.shadeless.toBool;
                }

                // culling
                if ("culling" in matAsset.props)
                {
                    matAsset.material.culling = matAsset.props.culling.toBool;
                }

                // colorWrite
                if ("colorWrite" in matAsset.props)
                {
                    matAsset.material.colorWrite = matAsset.props.colorWrite.toBool;
                }

                // depthWrite
                if ("depthWrite" in matAsset.props)
                {
                    matAsset.material.depthWrite = matAsset.props.depthWrite.toBool;
                }

                // useShadows
                if ("useShadows" in matAsset.props)
                {
                    matAsset.material.shadowsEnabled = matAsset.props.useShadows.toBool;
                }

                // useFog
                if ("useFog" in matAsset.props)
                {
                    matAsset.material.fogEnabled = matAsset.props.useFog.toBool;
                }

                // shadowFilter
                if ("shadowFilter" in matAsset.props)
                {
                    matAsset.material.shadowFilter = matAsset.props.shadowFilter.toInt;
                }

                // blendingMode
                if ("blendingMode" in matAsset.props)
                {
                    matAsset.material.blending = matAsset.props.blendingMode.toInt;
                }

                // transparency
                if ("transparency" in matAsset.props)
                {
                    matAsset.material.transparency = matAsset.props.transparency.toFloat;
                }

                return matAsset.material;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return materials[filename].material;
        }
    }

    Entity entity()
    {
        if (index.length)
        foreach(path; lineSplitter(index))
        {
            Entity e = entity(path);
        }

        return rootEntity;
    }

    Material createMaterial()
    {
        auto m = New!Material(scene.standardShader, assetOwner);
        return m;
    }

    bool fileExists(string filename)
    {
        FileStat stat;
        return boxfs.stat(filename, stat);
    }

    override void release()
    {
        Delete(boxfs);

        Delete(meshes);
        Delete(entities);
        Delete(textures);
        Delete(materials);

        Delete(assetOwner);

        rootEntity.release();

        if (index.length)
            Delete(index);
    }
}


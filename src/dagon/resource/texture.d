/*
Copyright (c) 2017-2020 Timur Gafarov

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

module dagon.resource.texture;

import std.stdio;
import std.path;

import dlib.core.memory;
import dlib.core.ownership;
import dlib.core.stream;
import dlib.core.compound;
import dlib.image.image;
/*
import dlib.image.io.bmp;
import dlib.image.io.png;
import dlib.image.io.tga;
import dlib.image.io.jpeg;
*/
import dlib.image.io.hdr;
import dlib.image.unmanaged;
import dlib.image.hdri;
import dlib.filesystem.filesystem;

import dagon.graphics.texture;
import dagon.graphics.containerimage;
import dagon.resource.asset;
import dagon.resource.stbi;
import dagon.resource.dds;

class TextureAsset: Asset
{
    UnmanagedImageFactory imageFactory;
    UnmanagedHDRImageFactory hdrImageFactory;
    Texture texture;

    this(UnmanagedImageFactory imgfac, UnmanagedHDRImageFactory hdrImgFac, Owner o)
    {
        super(o);
        imageFactory = imgfac;
        hdrImageFactory = hdrImgFac;
        texture = New!Texture(this);
    }

    ~this()
    {
        release();
    }

    override bool loadThreadSafePart(string filename, InputStream istrm, ReadOnlyFileSystem fs, AssetManager mngr)
    {
        string errMsg;

        if (filename.extension == ".hdr" ||
            filename.extension == ".HDR")
        {
            Compound!(SuperHDRImage, string) res;
            res = loadHDR(istrm, hdrImageFactory);
            texture.image = res[0];
            errMsg = res[1];
        }
        else if (filename.extension == ".dds" ||
                 filename.extension == ".DDS")
        {
            Compound!(ContainerImage, string) res;
            res = loadDDS(istrm);
            texture.image = res[0];
            errMsg = res[1];
        }
        else
        {
            Compound!(SuperImage, string) res;

            switch(filename.extension)
            {
                case ".bmp", ".BMP",
                     ".jpg", ".JPG", ".jpeg", ".JPEG",
                     ".png", ".PNG",
                     ".tga", ".TGA",
                     ".gif", ".GIF",
                     ".psd", ".PSD":
                    res = loadImageSTB(istrm, imageFactory);
                    break;
                default:
                    return false;
            }

            texture.image = res[0];
            errMsg = res[1];
        }

        if (texture.image !is null)
        {
            return true;
        }
        else
        {
            writeln(errMsg);
            return false;
        }
    }

    override bool loadThreadUnsafePart()
    {
        if (texture.image !is null)
        {
            texture.createFromImage(texture.image);
            if (texture.valid)
            {
                return true;
            }
            else
                return false;
        }
        else
        {
            return false;
        }
    }

    override void release()
    {
        if (texture)
            texture.release();
    }
}

TextureAsset textureAsset(AssetManager assetManager, string filename)
{
    TextureAsset asset;
    if (assetManager.assetExists(filename))
    {
        asset = cast(TextureAsset)assetManager.getAsset(filename);
    }
    else
    {
        asset = New!TextureAsset(assetManager.imageFactory, assetManager.hdrImageFactory, assetManager);
        assetManager.preloadAsset(asset, filename);
    }
    return asset;
}

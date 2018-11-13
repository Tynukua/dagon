/*
Copyright (c) 2017-2018 Timur Gafarov

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

module dagon.graphics.rc;

import dlib.math.vector;
import dlib.math.matrix;
import dlib.math.transformation;
import dlib.geometry.frustum;

import dagon.core.libs;
import dagon.core.event;
import dagon.graphics.environment;
import dagon.graphics.material;
import dagon.graphics.shader;

struct RenderingContext
{
    Matrix4x4f modelViewMatrix;

    Matrix4x4f modelMatrix;
    Matrix4x4f invModelMatrix;

    Vector3f cameraPosition;
    Vector3f prevCameraPosition;

    Matrix4x4f viewMatrix;
    Matrix4x4f invViewMatrix;

    Matrix4x4f viewRotationMatrix;
    Matrix4x4f invViewRotationMatrix;

    Matrix4x4f projectionMatrix;
    Matrix4x4f normalMatrix;

    Matrix4x4f prevViewMatrix;
    Matrix4x4f prevModelViewProjMatrix;
    Matrix4x4f blurModelViewProjMatrix;

    Frustum frustum;

    EventManager eventManager;
    Environment environment;

    Material material;

    Shader overrideShader;
    Material overrideMaterial;

    float time;
    float blurMask;

    bool depthPass;
    bool colorPass;
    bool shadowPass;

    int layer;

    bool ignoreTransparentEntities;
    bool ignoreOpaqueEntities;

    void init(EventManager emngr, Environment env)
    {
        modelViewMatrix = Matrix4x4f.identity;
        modelMatrix = Matrix4x4f.identity;
        invModelMatrix = Matrix4x4f.identity;
        cameraPosition = Vector3f(0.0f, 0.0f, 0.0f);
        prevCameraPosition = Vector3f(0.0f, 0.0f, 0.0f);
        viewMatrix = Matrix4x4f.identity;
        invViewMatrix = Matrix4x4f.identity;
        viewRotationMatrix = Matrix4x4f.identity;
        invViewRotationMatrix = Matrix4x4f.identity;
        projectionMatrix = Matrix4x4f.identity;
        normalMatrix = Matrix4x4f.identity;
        prevViewMatrix = Matrix4x4f.identity;
        prevModelViewProjMatrix = Matrix4x4f.identity;
        blurModelViewProjMatrix = Matrix4x4f.identity;
        eventManager = emngr;
        environment = env;
        overrideMaterial = null;
        time = 0.0f;
        depthPass = true;
        colorPass = true;
        blurMask = 1.0f;
        layer = 1;
        ignoreTransparentEntities = false;
        ignoreOpaqueEntities = false;
        shadowPass = false;
    }

    void initPerspective(EventManager emngr, Environment env, float fov, float znear, float zfar)
    {
        init(emngr, env);
        projectionMatrix = perspectiveMatrix(fov, emngr.aspectRatio, znear, zfar);
    }

    void initPerspective(EventManager emngr, Environment env, float fov, float aspect, float znear, float zfar)
    {
        init(emngr, env);
        projectionMatrix = perspectiveMatrix(fov, aspect, znear, zfar);
    }

    void initOrtho(EventManager emngr, Environment env, float znear, float zfar)
    {
        init(emngr, env);
        projectionMatrix = orthoMatrix(0.0f, emngr.windowWidth, emngr.windowHeight, 0.0f, znear, zfar);
    }

    void initOrtho(EventManager emngr, Environment env, float w, float h, float znear, float zfar)
    {
        init(emngr, env);
        projectionMatrix = orthoMatrix(0.0f, w, h, 0.0f, znear, zfar);
    }
}

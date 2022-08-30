/*
Copyright (c) 2022 Timur Gafarov

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
module dagon.graphics.texproc;

import std.stdio;

import dlib.core.memory;
import dlib.core.ownership;
import dlib.math.vector;
import dlib.math.matrix;
import dlib.math.transformation;
import dlib.image.color;
import dlib.text.str;

import dagon.core.bindings;
import dagon.graphics.texture;
import dagon.graphics.shader;
import dagon.graphics.state;
import dagon.graphics.screensurface;

class TextureCombinerShader: Shader
{
    String vs, fs;
    Texture[4] channels;
    
    this(Texture[4] channels, Owner owner)
    {
        vs = Shader.load("data/__internal/shaders/TextureCombiner/TextureCombiner.vert.glsl");
        fs = Shader.load("data/__internal/shaders/TextureCombiner/TextureCombiner.frag.glsl");

        auto myProgram = New!ShaderProgram(vs, fs, this);
        super(myProgram, owner);
        
        this.channels[] = channels[];
    }
    
    ~this()
    {
        vs.free();
        fs.free();
    }
    
    override void bindParameters(GraphicsState* state)
    {
        // Channel0
        glActiveTexture(GL_TEXTURE0);
        setParameter("texChannel0", cast(int)0);
        setParameter("valueChannel0", 0.0f);
        if (channels[0])
        {
            channels[0].bind();
            setParameterSubroutine("channel0", ShaderType.Fragment, "channel0Texture");
        }
        else
        {
            glBindTexture(GL_TEXTURE_2D, 0);
            setParameterSubroutine("channel0", ShaderType.Fragment, "channel0Value");
        }
        
        // Channel1
        glActiveTexture(GL_TEXTURE1);
        setParameter("texChannel1", cast(int)1);
        setParameter("valueChannel1", 0.0f);
        if (channels[1])
        {
            channels[1].bind();
            setParameterSubroutine("channel1", ShaderType.Fragment, "channel1Texture");
        }
        else
        {
            glBindTexture(GL_TEXTURE_2D, 0);
            setParameterSubroutine("channel1", ShaderType.Fragment, "channel1Value");
        }
        
        // Channel2
        glActiveTexture(GL_TEXTURE2);
        setParameter("texChannel2", cast(int)2);
        setParameter("valueChannel2", 0.0f);
        if (channels[2])
        {
            channels[2].bind();
            setParameterSubroutine("channel2", ShaderType.Fragment, "channel2Texture");
        }
        else
        {
            glBindTexture(GL_TEXTURE_2D, 0);
            setParameterSubroutine("channel2", ShaderType.Fragment, "channel2Value");
        }
        
        // Channel3
        glActiveTexture(GL_TEXTURE3);
        setParameter("texChannel3", cast(int)3);
        setParameter("valueChannel3", 0.0f);
        if (channels[3])
        {
            channels[3].bind();
            setParameterSubroutine("channel3", ShaderType.Fragment, "channel3Texture");
        }
        else
        {
            glBindTexture(GL_TEXTURE_2D, 0);
            setParameterSubroutine("channel3", ShaderType.Fragment, "channel3Value");
        }
        
        glActiveTexture(GL_TEXTURE0);
        
        super.bindParameters(state);
    }
    
    override void unbindParameters(GraphicsState* state)
    {
        super.unbindParameters(state);

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, 0);

        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, 0);

        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, 0);

        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, 0);

        glActiveTexture(GL_TEXTURE0);
    }
}

/// Combine up to 4 textures to one
void combineTextures(Texture[4] channels, Texture output)
{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, output.texture, 0);
    GLenum[1] drawBuffers = [GL_COLOR_ATTACHMENT0];
    glDrawBuffers(drawBuffers.length, drawBuffers.ptr);
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE)
    {
        writeln(status);
    }
    
    ScreenSurface screenSurface = New!ScreenSurface(null);
    TextureCombinerShader shader = New!TextureCombinerShader(channels, null);
    
    GraphicsState state;
    state.reset();
    state.resolution = Vector2f(output.size.width, output.size.height);
    
    glScissor(0, 0, output.size.width, output.size.height);
    glViewport(0, 0, output.size.width, output.size.height);
    
    glDisable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
    shader.bind();
    shader.bindParameters(&state);
    screenSurface.render(&state);
    shader.unbindParameters(&state);
    shader.unbind();
    glDepthMask(GL_TRUE);
    glEnable(GL_DEPTH_TEST);
    
    Delete(shader);
    Delete(screenSurface);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glDeleteFramebuffers(1, &framebuffer);
}

/// ditto
Texture combineTextures(uint w, uint h, Texture[4] channels, Owner owner)
{
    Texture output = New!Texture(owner);
    output.createBlank(w, h, 4, 8, false, Color4f(0.0f, 0.0f, 0.0f, 1.0f));
    combineTextures(channels, output);
    output.generateMipmap();
    return output;
}
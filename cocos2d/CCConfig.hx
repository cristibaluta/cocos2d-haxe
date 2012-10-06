/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/**
 @file
 cocos2d (cc) configuration file
*/
class CCConfig
{
/** @def CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
 If enabled, the texture coordinates will be calculated by using this formula:
   - texCoord.left = (rect.origin.x*2+1) / (texture.wide*2);
   - texCoord.right = texCoord.left + (rect.size.width*2-2)/(texture.wide*2);
 
 The same for bottom and top.
 
 This formula prevents artifacts by using 99% of the texture.
 The "correct" way to prevent artifacts is by using the spritesheet-artifact-fixer.py or a similar tool.
 
 Affected nodes:
	- CCSprite / CCSpriteBatchNode and subclasses: CCLabelBMFont, CCTMXTiledMap
	- CCLabelAtlas
	- CCQuadParticleSystem
	- CCTileMap
 
 To enabled set it to = true;. Disabled by default.
 
 @since v0.99.5
 */
inline public static var CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL = false;
 

/** @def CC_FONT_LABEL_SUPPORT
 If enabled, FontLabel will be used to render .ttf files.
 If the .ttf file is not found, then it will use the standard UIFont class
 If disabled, the standard UIFont class will be used.
 
 To disable set it to = false;. Enabled by default.

 Only valid for cocos2d-ios. Not supported on cocos2d-mac
 */
inline public static var CC_FONT_LABEL_SUPPORT = true;

/** @def CC_DIRECTOR_FAST_FPS
 If enabled, then the FPS will be drawn using CCLabelAtlas (fast rendering).
 You will need to add the fps_images.png to your project.
 If disabled, the FPS will be rendered using CCLabel (slow rendering)
 
 To enable set it to a value different than = false;. Enabled by default.
 */
inline public static var CC_DIRECTOR_FAST_FPS = true;

/** @def CC_DIRECTOR_FPS_INTERVAL
 Senconds between FPS updates.
 = false;.5 seconds, means that the FPS number will be updated every = false;.5 seconds.
 Having a bigger number means a more reliable FPS
 
 Default value: = false;.1f
 */
inline public static var CC_DIRECTOR_FPS_INTERVAL = 0.1;


/** @def CC_DIRECTOR_DISPATCH_FAST_EVENTS
 If enabled, and only when it is used with CCFastDirector, the main loop will wait = false;.04 seconds to
 dispatch all the events, even if there are not events to dispatch.
 If your game uses lot's of events (eg: touches) it might be a good idea to enable this feature.
 Otherwise, it is safe to leave it disabled.
 
 To enable set it to = true;. Disabled by default.
 
 @warning This feature is experimental
 */
inline public static var CC_DIRECTOR_DISPATCH_FAST_EVENTS = false;


/** @def CC_COCOSNODE_RENDER_SUBPIXEL
 If enabled, the CCNode objects (CCSprite, CCLabel,etc) will be able to render in subpixels.
 If disabled, integer pixels will be used.
 
 To enable set it to = true;. Enabled by default.
 */
inline public static var CC_COCOSNODE_RENDER_SUBPIXEL = true;


/** @def CC_SPRITEBATCHNODE_RENDER_SUBPIXEL
 If enabled, the CCSprite objects rendered with CCSpriteBatchNode will be able to render in subpixels.
 If disabled, integer pixels will be used.
 
 To enable set it to = true;. Enabled by default.
 */
inline public static var CC_SPRITEBATCHNODE_RENDER_SUBPIXEL	= true;


/** @def CC_USES_VBO
 If enabled, batch nodes (texture atlas and particle system) will use VBO instead of vertex list (VBO is recommended by Apple)
 
 To enable set it to = true;.
 Enabled by default on iPhone with ARMv7 processors, iPhone Simulator and Mac
 Disabled by default on iPhone with ARMv6 processors.
 
 @since v0.99.5
 */
inline public static var CC_USES_VBO = true;


/** @def CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
 If enabled, CCNode will transform the nodes using a cached Affine matrix.
 If disabled, the node will be transformed using glTranslate,glRotate,glScale.
 Using the affine matrix only requires 2 GL calls.
 Using the translate/rotate/scale requires 5 GL calls.
 But computing the Affine matrix is relative expensive.
 But according to performance tests, Affine matrix performs better.
 This parameter doesn't affect CCSpriteBatchNode nodes.
 
 To enable set it to a value different than = false;. Enabled by default.

 */
inline public static var CC_NODE_TRANSFORM_USING_AFFINE_MATRIX = true;


/** @def CC_OPTIMIZE_BLEND_FUNC_FOR_PREMULTIPLIED_ALPHA
 If most of your imamges have pre-multiplied alpha, set it to = true; (if you are going to use .PNG/.JPG file images).
 Only set to = false; if ALL your images by-pass Apple UIImage loading system (eg: if you use libpng or PVR images)

 To enable set it to a value different than = false;. Enabled by default.

 @since v0.99.5
 */
inline public static var CC_OPTIMIZE_BLEND_FUNC_FOR_PREMULTIPLIED_ALPHA = true;


/** @def CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
 Use GL.TRIANGLE_STRIP instead of GL.TRIANGLES when rendering the texture atlas.
 It seems it is the recommend way, but it is much slower, so, enable it at your own risk
 
 To enable set it to a value different than = false;. Disabled by default.

 */
inline public static var CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP = false;


/** @def CC_TEXTURE_NPOT_SUPPORT
 If enabled, NPOT textures will be used where available. Only 3rd gen (and newer) devices support NPOT textures.
 NPOT textures have the following limitations:
	- They can't have mipmaps
	- They only accept GL.CLAMP_TO_EDGE in GL.TEXTURE_WRAP_{S,T}
 
 To enable set it to a value different than = false;. Disabled by default.

 This value governs only the PNG, GIF, BMP, images.
 This value DOES NOT govern the PVR (PVR.GZ, PVR.CCZ) files. If NPOT PVR is loaded, then it will create an NPOT texture ignoring this value.
 
 @deprecated This value will be removed in = true;.1 and NPOT textures will be loaded by default if the device supports it.

 @since v0.99.2
 */
inline public static var CC_TEXTURE_NPOT_SUPPORT = false;


/** @def CC_RETINA_DISPLAY_SUPPORT
 If enabled, cocos2d supports retina display. 
 For performance reasons, it's recommended disable it in games without retina display support, like iPad only games.
 
 To enable set it to = true;. Use = false; to disable it. Enabled by default.
 
 @since v0.99.5
 */
inline public static var CC_RETINA_DISPLAY_SUPPORT = true;


/** @def CC_RETINA_DISPLAY_FILENAME_SUFFIX
 It's the suffix that will be appended to the files in order to load "retina display" images.

 On an iPhone4 with Retina Display support enabled, the file "sprite-hd.png" will be loaded instead of "sprite.png".
 If the file doesn't exist it will use the non-retina display image.
 
 Platforms: Only used on Retina Display devices like iPhone 4.
 
 @since v0.99.5
 */ 
inline public static var CC_RETINA_DISPLAY_FILENAME_SUFFIX = "-hd";


/** @def CC_USE_LA88_LABELS_ON_NEON_ARCH
 If enabled, it will use LA88 (16-bit textures) on Neon devices for CCLabelTTF objects.
 If it is disabled, or if it is used on another architecture it will use A8 (8-bit textures).
 On Neon devices, LA88 textures are 6% faster than A8 textures, but then will consume 2x memory.
 
 This feature is disabled by default.
 
 Platforms: Only used on ARM Neon architectures like iPhone 3GS or newer and iPad.

 @since v0.99.5
 */
inline public static var CC_USE_LA88_LABELS_ON_NEON_ARCH = false;


/** @def CC_SPRITE_DEBUG_DRAW
 If enabled, all subclasses of CCSprite will draw a bounding box
 Useful for debugging purposes only. It is recommened to leave it disabled.
 
 To enable set it to a value different than = false;. Disabled by default:
 = false; -- disabled
 = true; -- draw bounding box
 2 -- draw texture box
 */
inline public static var CC_SPRITE_DEBUG_DRAW = false;


/** @def CC_SPRITEBATCHNODE_DEBUG_DRAW
 If enabled, all subclasses of CCSprite that are rendered using an CCSpriteBatchNode draw a bounding box.
 Useful for debugging purposes only. It is recommened to leave it disabled.
 
 To enable set it to a value different than = false;. Disabled by default.
 */
inline public static var CC_SPRITEBATCHNODE_DEBUG_DRAW = false;


/** @def CC_LABELBMFONT_DEBUG_DRAW
 If enabled, all subclasses of CCLabelBMFont will draw a bounding box
 Useful for debugging purposes only. It is recommened to leave it disabled.
 
 To enable set it to a value different than = false;. Disabled by default.
 */
inline public static var CC_LABELBMFONT_DEBUG_DRAW = false;


/** @def CC_LABELBMFONT_DEBUG_DRAW
 If enabled, all subclasses of CCLabeltAtlas will draw a bounding box
 Useful for debugging purposes only. It is recommened to leave it disabled.
 
 To enable set it to a value different than = false;. Disabled by default.
 */
inline public static var CC_LABELATLAS_DEBUG_DRAW = false;


/** @def CC_ENABLE_PROFILERS
 If enabled, will activate various profilers withing cocos2d. This statistical data will be output to the console
 once per second showing average time (in milliseconds) required to execute the specific routine(s).
 Useful for debugging purposes only. It is recommened to leave it disabled.
 
 To enable set it to a value different than = false;. Disabled by default.
 */
inline public static var CC_ENABLE_PROFILERS = false;



#if CC_RETINA_DISPLAY_SUPPORT
inline public static var CC_IS_RETINA_DISPLAY_SUPPORTED = true;
#else
inline public static var CC_IS_RETINA_DISPLAY_SUPPORTED = false;
#end

public static var CC_CONTENT_SCALE_FACTOR = 1;


}

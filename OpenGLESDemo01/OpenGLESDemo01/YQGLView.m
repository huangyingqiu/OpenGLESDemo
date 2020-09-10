//
//  YQGLView.m
//  OpenGLESDemo01
//
//  Created by MAC on 2020/9/8.
//  Copyright © 2020 MAC. All rights reserved.
//

#import "YQGLView.h"
#import <OpenGLES/ES2/gl.h>

@interface YQGLView()

@property (nonatomic , strong) EAGLContext *context;
@property (nonatomic , strong) CAEAGLLayer *eagLayer;

@property (nonatomic , assign) GLuint program;
@property (nonatomic , assign) GLuint renderBuffer;
@property (nonatomic , assign) GLuint frameBuffer;

@end

@implementation YQGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [self setupLayer];
    [self setupContext];
    [self deleteBuffers];
    
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    [self render];
}

- (void)setupLayer {
    self.eagLayer = (CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.eagLayer.opaque = YES;
}

- (void)setupContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Fail to set current context");
    }
    self.context = context;
}

- (void)setupRenderBuffer {
    // 创建帧缓冲区
    glGenRenderbuffers(1, &_renderBuffer);
    // 绑定帧缓冲区到渲染管线
    glBindRenderbuffer(GL_RENDERBUFFER, self.renderBuffer);
    // 为绘制缓冲区分配存储区：将CAEAGLLayer的绘制存储区作为绘制缓冲区的存储区
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eagLayer];
}

- (void)setupFrameBuffer {
    // 创建绘制缓冲区
    glGenFramebuffers(1, &_frameBuffer);
    // 邦定绘制缓冲区到渲染管线
    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);
    // 将绘制缓冲区邦定到帧缓冲区
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderBuffer);
}

- (void)deleteBuffers {
    glDeleteFramebuffers(1, &_frameBuffer);
    self.frameBuffer = 0;
    glDeleteRenderbuffers(1, &_renderBuffer);
    self.renderBuffer = 0;
}

- (void)render {
    // 清屏为白色
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [[UIScreen mainScreen] scale]; //获取视图放大倍数，可以把scale设置为1试试
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale); //设置视口大小
    
    //读取文件路径
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"fsh"];
    
    BOOL buildProgramSuccess = [self buildProgramWithShaders:vertFile frag:fragFile];
    if (!buildProgramSuccess) {
        return;
    }
    glUseProgram(self.program); //成功便使用，避免由于未使用导致的的bug
    
    GLfloat attrArr[] =
    {
        1.0f, -0.5f, 0.0f, //右下
        0.0f, 0.5f, 0.0f,  //上
        -1.0f, -0.5f, 0.0f //左下
    };
    
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    //获取参数位置
    GLuint position = glGetAttribLocation(self.program, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, NULL);
    glEnableVertexAttribArray(position);
    
    //绘制三个顶点的三角形
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    //EACAGLContext 渲染OpenGL绘制好的图像到EACAGLLayer
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)buildProgramWithShaders:(NSString *)vert frag:(NSString *)frag {
    GLuint verShader, fragShader;
    self.program = glCreateProgram();
    
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(self.program, verShader);
    glAttachShader(self.program, fragShader);
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    //链接
    glLinkProgram(self.program);
    GLint linkSuccess;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) { //连接错误
        GLchar messages[256];
        glGetProgramInfoLog(self.program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        return NO;
    }
    
    return YES;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = [content UTF8String];
    
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    
    glCompileShader(*shader);
}

@end

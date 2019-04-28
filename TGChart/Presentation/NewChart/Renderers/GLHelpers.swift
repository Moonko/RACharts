import GLKit

func compileShader(_ shaderName: String, shaderType: GLenum) -> GLuint {
    let shaderPath: String! = Bundle.main.path(forResource: shaderName, ofType: "glsl")
    let shaderString = try! NSString(contentsOfFile:shaderPath, encoding: String.Encoding.utf8.rawValue)
    let shaderHandle: GLuint = glCreateShader(shaderType)
    if shaderHandle == 0 {
        print("Couldn't create shader")
    }
    var shaderStringUTF8 = shaderString.utf8String
    var shaderStringLength: GLint = GLint(Int32(shaderString.length))
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength)
    glCompileShader(shaderHandle)
    var compileSuccess: GLint = GLint()
    glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
    if (compileSuccess == GL_FALSE) {
        print("Failed to compile shader!")
        exit(1);
    }
    return shaderHandle
}

extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride * self.count
    }
}

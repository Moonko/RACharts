import UIKit
import GLKit

final class PercentStackedAreaChartRenderer: GLKView, ChartRenderer {

    var needsRendering: Bool = false

    var viewport: Viewport!

    var selectionType: ChartSelectionType {
        return .none
    }

    var startsFromZero: Bool {
        return true
    }

    private var matrix = [GLfloat]()
    private var points = [GLfloat]()
    private var colors = [GLfloat]()

    private var lineWidth: GLfloat = 1

    private var linesCount = 0
    private var pointsCount = 0

    private var positionSlot = GLuint()
    private var colorSlot = GLuint()
    private var programHandle = GLuint()

    init() {
        super.init(frame: .zero)

        backgroundColor = .clear

        drawableMultisample = .multisample4X

        let eaglContext = EAGLContext(api: .openGLES2)!
        EAGLContext.setCurrent(eaglContext)
        context = eaglContext

        let vertexShader: GLuint = compileShader("SimpleVertex", shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShader: GLuint = compileShader("SimpleFragment", shaderType: GLenum(GL_FRAGMENT_SHADER))
        programHandle = glCreateProgram()
        glAttachShader(programHandle, vertexShader)
        glAttachShader(programHandle, fragmentShader)
        glLinkProgram(programHandle)

//        glEnable(GLenum(GL_BLEND))
//        glBlendFuncSeparate(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA), GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA));
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateXValues(with timestampPoints: [CGFloat], linesCount: Int) {
        pointsCount = timestampPoints.count
        self.linesCount = linesCount

        points.removeAll()
        (0 ..< linesCount).forEach { _ in
            timestampPoints.forEach { timestampPoint in
                let glPoint = -1 + timestampPoint * 2
                points.append(GLfloat(glPoint))
                points.append(-1)
                points.append(GLfloat(glPoint))
                points.append(-1)
            }
        }
    }

    func updateYValues(with valuePoints: [[GLfloat]]) {
        valuePoints.enumerated().forEach {
            let channelIndex = $0.offset
            let channelValues = $0.element

            (0 ..< channelValues.count).forEach { valueIndex in
                let value = channelValues[valueIndex]

                let glValue = -(-1 + value * 2)
                points[pointsCount * 4 * channelIndex + 1 + valueIndex * 4] = glValue
            }
        }
    }

    func update(with matrices: [[CGFloat]], colors: [CGFloat]) {
        self.matrix = matrices.first!.map { GLfloat($0) }
        self.colors = colors.map { GLfloat($0) }
        self.lineWidth = GLfloat(ceil(viewport.spacingX) * UIScreen.main.scale)
    }

    override func draw(_ rect: CGRect) {
        glClearColor(0, 0, 0, 0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        guard !matrix.isEmpty else { return }

        glUseProgram(programHandle)

        glLineWidth(lineWidth)

        let colorHandle = GLint(glGetUniformLocation(programHandle, "vColor"))

        let matrixHandle = GLint(glGetUniformLocation(programHandle, "uMatrix"))

        let aPosition = GLuint(glGetAttribLocation(programHandle, "a_position"))
        glVertexAttribPointer(aPosition,
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              0,
                              points)
        glEnableVertexAttribArray(aPosition)

        glUniformMatrix4fv(matrixHandle, 1, GLboolean(GL_FALSE), matrix)
        for i in (0 ..< linesCount) {
            let colorIndex = (linesCount - 1 - i) * 4
            glUniform4f(colorHandle, colors[colorIndex], colors[colorIndex+1], colors[colorIndex+2], colors[colorIndex+3])
            glDrawArrays(GLenum(GL_TRIANGLE_STRIP),
                         GLint(pointsCount * (linesCount - 1 - i) * 2),
                         GLsizei(pointsCount * 2))
        }
    }
}
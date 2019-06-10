package com.michael.circularprogressbar

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.util.Range
import android.view.View
import android.view.animation.DecelerateInterpolator
import androidx.core.content.res.use

/**
 * Circular Progress Bar
 */
class CircularProgressBar
    @JvmOverloads
    constructor(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0) : View(context, attrs, defStyleAttr) {

    /**
     * 進捗率（パーセント）
     */
    var progress : Int = 0
        set(v) {
            if(field!=v) {
                field = v
                val animator = ValueAnimator.ofFloat(mSweepAngle, calcSweepAngleFromProgress(v.toFloat()))
                animator.interpolator = DecelerateInterpolator()
                // Animation duration for progress change
                val mAnimationDuration = 400
                animator.duration = mAnimationDuration.toLong()
                animator.addUpdateListener { valueAnimator ->
                    mSweepAngle = valueAnimator.animatedValue as Float
                    invalidate()
                }
                animator.start()
            }
        }


    // region 配色

    /**
     * プログレスリングのプログレス中のところの色
     */
    var progressColor:Int = Color.BLACK
    /**
     * プログレスリングのプログレス中じゃないところの色
     */
    var ringBaseColor:Int = Color.LTGRAY
    /**
     * リングの内側の色（テキストの背景）
     */
    var insideRingColor:Int = Color.WHITE
    /**
     * テキストの色
     */
    var textColor = Color.BLACK

    // endregion

    // region サイズ・表示オプション

    /**
     * リングの太さ
     * 半径に対する比率で指定
     */
    var ringThicknessRatio:Float = 0.25f

    /**
     * true:  リングの端点をRoundにする
     * false: Butt（デフォルト）
     */
    var roundedCorners:Boolean = false

    /**
     * true: パーセント文字列を表示する（デフォルト）
     */
    var showText:Boolean = true

    // endregion

    // region Internals

    private var mViewWidth: Float = 0f
    private var mViewHeight: Float = 0f

    private var mSweepAngle = 0f              // How long to sweep from mStartAngle
    private val mMaxSweepAngle = 360f         // Max degrees to sweep = full circle
    private val mMaxProgress = 100             // Max progress to use
    private val mPaint: Paint                 // Allocate paint outside onDraw to avoid unnecessary object creation

    init {
        mPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        context.obtainStyledAttributes(attrs, R.styleable.CircularProgressBar).use { ary ->
            progressColor = ary.getColor(R.styleable.CircularProgressBar_progressColor, progressColor)
            ringBaseColor = ary.getColor(R.styleable.CircularProgressBar_ringBaseColor, ringBaseColor)
            insideRingColor = ary.getColor(R.styleable.CircularProgressBar_insideRingColor, insideRingColor)
            textColor = ary.getColor(R.styleable.CircularProgressBar_textColor, textColor)
            showText = ary.getBoolean(R.styleable.CircularProgressBar_showText, showText)
            ringThicknessRatio = Range(0f,1f).clamp(ary.getFloat(R.styleable.CircularProgressBar_ringThicknessRatio, ringThicknessRatio))
        }
    }


    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        initMeasurements()
        drawBackground(canvas)
        drawOutlineArc(canvas)

        if (showText) {
            drawText(canvas)
        }
    }

    private fun initMeasurements() {
        mViewWidth = width.toFloat()
        mViewHeight = height.toFloat()
    }

    private val diameter:Float
        get() = Math.min(mViewWidth, mViewHeight)

    private val strokeWidth:Float
        get() = (diameter/2) * ringThicknessRatio

    private fun drawBackground(canvas: Canvas) {
        val pad = strokeWidth / 2f
        val c = diameter / 2f

        mPaint.color = insideRingColor
        mPaint.strokeWidth = 0f
        mPaint.isAntiAlias = true
        mPaint.style = Paint.Style.FILL

        canvas.drawCircle(c,c,c, mPaint)

        mPaint.color = ringBaseColor
        mPaint.strokeWidth = strokeWidth
        mPaint.isAntiAlias = true
        mPaint.style = Paint.Style.STROKE

        canvas.drawCircle(c,c,c-pad, mPaint)
    }

    private fun drawOutlineArc(canvas: Canvas) {
        val pad = strokeWidth / 2f
        val outerOval = RectF(pad, pad, diameter - pad, diameter - pad)

        mPaint.color = progressColor
        mPaint.strokeWidth = strokeWidth
        mPaint.isAntiAlias = true
        mPaint.strokeCap = if (roundedCorners) Paint.Cap.ROUND else Paint.Cap.BUTT
        mPaint.style = Paint.Style.STROKE
        // Always start from top (default is: "3 o'clock on a watch.")
        val mStartAngle = -90f
        canvas.drawArc(outerOval, mStartAngle, mSweepAngle, false, mPaint)
    }

    private fun drawText(canvas: Canvas) {
        mPaint.textSize = diameter/1.41421356f/3
        mPaint.typeface = Typeface.DEFAULT_BOLD
        mPaint.textAlign = Paint.Align.CENTER
        mPaint.strokeWidth = 0f
        mPaint.color = textColor
        mPaint.style = Paint.Style.FILL

        // Center text
        val xPos = canvas.width / 2
        val yPos = (canvas.height / 2 - (mPaint.descent() + mPaint.ascent()) / 2).toInt()

        canvas.drawText("$progress%", xPos.toFloat(), yPos.toFloat(), mPaint)
    }

    private fun calcSweepAngleFromProgress(progress: Float): Float {
        return mMaxSweepAngle / mMaxProgress * progress
    }

    // endregion

}

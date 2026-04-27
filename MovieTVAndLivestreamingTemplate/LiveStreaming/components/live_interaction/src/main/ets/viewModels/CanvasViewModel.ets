import { LikeIcon } from '../models/LikeIcon'


@ObservedV2
export class CanvasViewModel {
  likeIcons: LikeIcon[] = []
  @Trace likeNum: number = 0
  private animationId: number = 0
  private emojis: string[] = [
    '❤️', '🧡', '💛', '💚', '💙', '💜',
    '🐻', '🐼', '🐨', '🦁', '🐯', '🦊',
    '🎁', '🎀', '🎉', '👍', '✨', '⭐'
  ]

  startAnimation(context: CanvasRenderingContext2D) {
    this.animationId = setInterval(() => {
      this.updateIcons()
      this.drawAllIcons(context)
    }, 16)
  }

  stopAnimation() {
    clearInterval(this.animationId)
  }

  createIcon(x: number, y: number, radius: number, emoji: string): LikeIcon {
    const initialScale = 0.4 + Math.random() * 0.2
    const maxScale = 1.0 + Math.random() * 0.3
    const maxOffset = 8 + Math.random() * 7
    const direction = Math.random() > 0.5 ? 1 : -1

    return {
      x: x,
      y: y,
      initialX: x,
      initialY: y,
      radius: radius,
      emoji: emoji,
      fontSize: Math.floor(radius * 1.2),
      opacity: 1.0,
      createTime: Date.now(),
      lifespan: 1000,
      scale: initialScale,
      initialScale: initialScale,
      maxScale: maxScale,
      maxOffset: maxOffset,
      direction: direction
    }
  }

  getRandomEmoji(): string {
    return this.emojis[Math.floor(Math.random() * this.emojis.length)]
  }

  addLikeIcon(x: number, y: number) {
    const radius = 80 + Math.random() * 20
    const emoji = this.getRandomEmoji()
    this.likeIcons.push(this.createIcon(x, y, radius, emoji))
    this.likeNum++
  }

  updateIcons() {
    const currentTime = Date.now()
    this.likeIcons = this.likeIcons.filter(icon => {
      const existTime = currentTime - icon.createTime
      if (existTime < icon.lifespan) {
        this.updateIconState(icon, existTime)
        return true
      }
      return false
    })
  }

  updateIconState(icon: LikeIcon, existTime: number) {
    const progress = existTime / icon.lifespan
    const verticalDistance = 120 * Math.pow(progress, 0.7)
    icon.y = icon.initialY - verticalDistance

    let horizontalOffset = 0
    if (progress < 0.25) {
      horizontalOffset = 0
    } else if (progress < 0.5) {
      const phaseProgress = (progress - 0.25) / 0.25
      horizontalOffset = -icon.maxOffset * phaseProgress * icon.direction
    } else if (progress < 0.75) {
      const phaseProgress = (progress - 0.5) / 0.25
      horizontalOffset = icon.maxOffset * (2 * phaseProgress - 1) * icon.direction
    } else {
      const phaseProgress = (progress - 0.75) / 0.25
      horizontalOffset = icon.maxOffset * (1 - 2 * phaseProgress) * icon.direction
    }
    icon.x = icon.initialX + horizontalOffset

    if (progress < 0.2) {
      icon.scale = icon.initialScale + (icon.maxScale - icon.initialScale) * (progress / 0.2)
    } else {
      icon.scale = icon.maxScale
    }

    if (progress > 0.6) {
      icon.opacity = 1.0 - ((progress - 0.6) / 0.4)
    } else {
      icon.opacity = 1.0
    }
  }

  drawAllIcons(context: CanvasRenderingContext2D) {
    context.clearRect(0, 0, context.width, context.height)
    this.likeIcons.forEach(icon => {
      context.save()
      context.globalAlpha = icon.opacity
      context.translate(icon.x, icon.y)
      context.scale(icon.scale, icon.scale)
      context.translate(-icon.x, -icon.y)
      context.font = `${icon.fontSize}px`
      context.textAlign = 'center'
      context.textBaseline = 'middle'
      context.fillText(icon.emoji, icon.x, icon.y)
      context.restore()
    })
  }
}
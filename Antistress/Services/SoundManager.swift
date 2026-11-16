import Foundation
import AVFoundation
import Combine

public final class SoundManager: ObservableObject {
    public static let shared = SoundManager()

    private let keySoundEnabled = "antistress_sound_enabled"
    private let sampleRate: Double = 44100.0

    @Published public var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: keySoundEnabled)
        }
    }

    public enum SoundKey: Int {
        case pop = 1
        case popDeep = 2
        case switchOn = 3
        case switchOff = 4
        case buttonClick = 5
        case penClick = 6
        case penRelease = 7
        case steelBall = 8
        case bamboo = 9
        case waterDrop = 10
        case woodChop = 11
        case chalk = 12
        case squish = 13
        case squeegee = 14
        case sparkle = 15
        case sandRake = 16
        case xyloBase = 100 // 100..107
    }

    private var soundDataMap: [Int: Data] = [:]
    private var activePlayers: [AVAudioPlayer] = []
    private let lock = NSLock()

    private init() {
        if UserDefaults.standard.object(forKey: keySoundEnabled) != nil {
            self.isSoundEnabled = UserDefaults.standard.bool(forKey: keySoundEnabled)
        } else {
            self.isSoundEnabled = true
        }

        configureAudioSession()
        generateAllSounds()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession configure warning: \(error)")
        }
    }

    // MARK: - Public Play API

    public func play(_ soundKey: SoundKey, volume: Float = 1.0, pitchMultiplier: Float = 1.0) {
        play(keyInt: soundKey.rawValue, volume: volume, pitchMultiplier: pitchMultiplier)
    }

    public func play(keyInt: Int, volume: Float = 1.0, pitchMultiplier: Float = 1.0) {
        guard isSoundEnabled else { return }

        guard let data = soundDataMap[keyInt] else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            do {
                let player = try AVAudioPlayer(data: data)
                player.volume = min(1.0, max(0.0, volume))
                player.enableRate = true
                player.rate = max(0.5, min(2.0, pitchMultiplier * Float.random(in: 0.98...1.02)))
                player.prepareToPlay()
                player.play()

                self.lock.lock()
                self.activePlayers.append(player)
                // Clean up finished players
                self.activePlayers.removeAll { !$0.isPlaying }
                if self.activePlayers.count > 24 {
                    self.activePlayers.removeFirst()
                }
                self.lock.unlock()
            } catch {
                print("Failed to play sound: \(error)")
            }
        }
    }

    public func playPop() { play(.pop, volume: 0.9) }
    public func playPopDeep() { play(.popDeep, volume: 1.0) }
    public func playSwitch(isOn: Bool) { play(isOn ? .switchOn : .switchOff, volume: 0.85) }
    public func playButtonClick() { play(.buttonClick, volume: 0.8) }
    public func playPenClick(isRelease: Bool) { play(isRelease ? .penRelease : .penClick, volume: 0.9) }
    public func playBambooChime() { play(.bamboo, volume: 0.85, pitchMultiplier: Float.random(in: 0.9...1.1)) }
    public func playWaterDrop() { play(.waterDrop, volume: 0.75, pitchMultiplier: Float.random(in: 0.95...1.05)) }
    public func playWoodChop() { play(.woodChop, volume: 1.0) }
    public func playChalk() { play(.chalk, volume: 0.6) }
    public func playSquish() { play(.squish, volume: 0.8) }
    public func playSqueegee() { play(.squeegee, volume: 0.65) }
    public func playSparkle() { play(.sparkle, volume: 0.7) }
    public func playSandRake() { play(.sandRake, volume: 0.6) }

    public func playBallImpact(velocityRatio: Float) {
        let vol = max(0.15, min(1.0, velocityRatio))
        let pitch = 0.95 + (velocityRatio * 0.12)
        play(.steelBall, volume: vol, pitchMultiplier: pitch)
    }

    public func playXylophoneNote(index: Int, volume: Float = 1.0) {
        let clamped = max(0, min(7, index))
        play(keyInt: SoundKey.xyloBase.rawValue + clamped, volume: volume)
    }

    // MARK: - Procedural Sound Generation

    private func generateAllSounds() {
        soundDataMap[SoundKey.pop.rawValue] = makeWav(generatePop(freq: 480.0, duration: 0.08))
        soundDataMap[SoundKey.popDeep.rawValue] = makeWav(generatePop(freq: 260.0, duration: 0.12))
        soundDataMap[SoundKey.switchOn.rawValue] = makeWav(generateSwitch(startFreq: 1200.0, endFreq: 600.0, duration: 0.04))
        soundDataMap[SoundKey.switchOff.rawValue] = makeWav(generateSwitch(startFreq: 700.0, endFreq: 350.0, duration: 0.04))
        soundDataMap[SoundKey.buttonClick.rawValue] = makeWav(generateButtonClick())
        soundDataMap[SoundKey.penClick.rawValue] = makeWav(generatePenClick(isRelease: false))
        soundDataMap[SoundKey.penRelease.rawValue] = makeWav(generatePenClick(isRelease: true))
        soundDataMap[SoundKey.steelBall.rawValue] = makeWav(generateSteelBall())
        soundDataMap[SoundKey.bamboo.rawValue] = makeWav(generateBambooChime())
        soundDataMap[SoundKey.waterDrop.rawValue] = makeWav(generateWaterDrop())
        soundDataMap[SoundKey.woodChop.rawValue] = makeWav(generateWoodChop())
        soundDataMap[SoundKey.chalk.rawValue] = makeWav(generateChalk())
        soundDataMap[SoundKey.squish.rawValue] = makeWav(generateSquish())
        soundDataMap[SoundKey.squeegee.rawValue] = makeWav(generateSqueegee())
        soundDataMap[SoundKey.sparkle.rawValue] = makeWav(generateSparkle())
        soundDataMap[SoundKey.sandRake.rawValue] = makeWav(generateSandRake())

        let xyloFreqs: [Double] = [523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77, 1046.50]
        for (i, f) in xyloFreqs.enumerated() {
            soundDataMap[SoundKey.xyloBase.rawValue + i] = makeWav(generateXylophoneTone(freq: f))
        }
    }

    private func generatePop(freq: Double, duration: Double) -> [Int16] {
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 40.0)
            let mod = freq * (1.0 + exp(-t * 80.0) * 1.5)
            let sine = sin(2.0 * .pi * mod * t)
            let noise = (Double.random(in: -1.0...1.0)) * exp(-t * 90.0) * 0.3
            let s = max(-1.0, min(1.0, (sine + noise) * env * 0.9))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateSwitch(startFreq: Double, endFreq: Double, duration: Double) -> [Int16] {
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let frac = t / duration
            let f = startFreq + (endFreq - startFreq) * frac
            let env = exp(-t * 60.0)
            let square = sin(2.0 * .pi * f * t) > 0 ? 0.6 : -0.6
            let noise = Double.random(in: -0.3...0.3) * exp(-t * 80.0)
            let s = max(-1.0, min(1.0, (square + noise) * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateButtonClick() -> [Int16] {
        let duration = 0.03
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 90.0)
            let click = sin(2.0 * .pi * 850.0 * t) * 0.7 + Double.random(in: -0.4...0.4)
            let s = max(-1.0, min(1.0, click * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generatePenClick(isRelease: Bool) -> [Int16] {
        let duration = 0.045
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        let f1 = isRelease ? 1800.0 : 2400.0
        let f2 = isRelease ? 900.0 : 1200.0
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 70.0)
            let metallic = sin(2.0 * .pi * f1 * t) * 0.5 + sin(2.0 * .pi * f2 * t) * 0.35 + Double.random(in: -0.2...0.2)
            let s = max(-1.0, min(1.0, metallic * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateSteelBall() -> [Int16] {
        let duration = 0.07
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 50.0)
            let ping = sin(2.0 * .pi * 3200.0 * t) * 0.45 + sin(2.0 * .pi * 4800.0 * t) * 0.35 + sin(2.0 * .pi * 1800.0 * t) * 0.25
            let s = max(-1.0, min(1.0, ping * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateBambooChime() -> [Int16] {
        let duration = 0.28
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        let baseFreq = Double.random(in: 420.0...680.0)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 14.0)
            let hollow = sin(2.0 * .pi * baseFreq * t) * 0.6 + sin(2.0 * .pi * (baseFreq * 2.3) * t) * 0.25
            let thud = exp(-t * 60.0) * sin(2.0 * .pi * 140.0 * t) * 0.4
            let s = max(-1.0, min(1.0, (hollow + thud) * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateWaterDrop() -> [Int16] {
        let duration = 0.16
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 18.0)
            let sweepFreq = 600.0 + (1400.0 * exp(-t * 22.0))
            let drop = sin(2.0 * .pi * sweepFreq * t) * 0.8
            let s = max(-1.0, min(1.0, drop * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateWoodChop() -> [Int16] {
        let duration = 0.18
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 25.0)
            let crack = (Double.random(in: -1.0...1.0)) * exp(-t * 60.0) * 0.8
            let thump = sin(2.0 * .pi * 120.0 * t) * 0.6 * exp(-t * 30.0)
            let s = max(-1.0, min(1.0, (crack + thump) * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateChalk() -> [Int16] {
        let duration = 0.08
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 30.0)
            let rasp = Double.random(in: -0.8...0.8) * 0.6 + sin(2.0 * .pi * 3800.0 * t) * 0.2
            let s = max(-1.0, min(1.0, rasp * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateSquish() -> [Int16] {
        let duration = 0.14
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 20.0)
            let wobble = sin(2.0 * .pi * 180.0 * t + sin(2.0 * .pi * 25.0 * t)) * 0.5
            let squelch = Double.random(in: -0.3...0.3) * exp(-t * 35.0)
            let s = max(-1.0, min(1.0, (wobble + squelch) * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateSqueegee() -> [Int16] {
        let duration = 0.1
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 15.0)
            let glide = sin(2.0 * .pi * 950.0 * t) * 0.25 + Double.random(in: -0.4...0.4) * 0.35
            let s = max(-1.0, min(1.0, glide * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateSparkle() -> [Int16] {
        let duration = 0.35
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 8.0)
            let bell1 = sin(2.0 * .pi * 2093.0 * t) * 0.5
            let bell2 = sin(2.0 * .pi * 3136.0 * t) * 0.35
            let bell3 = sin(2.0 * .pi * 4186.0 * t) * 0.2
            let s = max(-1.0, min(1.0, (bell1 + bell2 + bell3) * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateSandRake() -> [Int16] {
        let duration = 0.12
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 12.0)
            let grit = Double.random(in: -1.0...1.0) * 0.35
            let s = max(-1.0, min(1.0, grit * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    private func generateXylophoneTone(freq: Double) -> [Int16] {
        let duration = 0.55
        let count = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let env = exp(-t * 5.5)
            let f1 = sin(2.0 * .pi * freq * t) * 0.7
            let f2 = sin(2.0 * .pi * freq * 2.756 * t) * 0.2 * exp(-t * 12.0)
            let f3 = sin(2.0 * .pi * freq * 5.404 * t) * 0.1 * exp(-t * 20.0)
            let s = max(-1.0, min(1.0, (f1 + f2 + f3) * env))
            samples[i] = Int16(s * Double(Int16.max))
        }
        return samples
    }

    // MARK: - WAV Byte Packing

    private func makeWav(_ samples: [Int16]) -> Data {
        var data = Data()
        let sampleRateInt = UInt32(sampleRate)
        let byteDataLen = UInt32(samples.count * 2)
        let totalChunkSize = byteDataLen + 36

        // RIFF header
        data.append(contentsOf: "RIFF".utf8)
        data.append(contentsOf: withUnsafeBytes(of: totalChunkSize.littleEndian) { Array($0) })
        data.append(contentsOf: "WAVE".utf8)

        // fmt chunk
        data.append(contentsOf: "fmt ".utf8)
        let subchunk1Size: UInt32 = 16
        data.append(contentsOf: withUnsafeBytes(of: subchunk1Size.littleEndian) { Array($0) })
        let audioFormat: UInt16 = 1 // PCM
        data.append(contentsOf: withUnsafeBytes(of: audioFormat.littleEndian) { Array($0) })
        let numChannels: UInt16 = 1 // Mono
        data.append(contentsOf: withUnsafeBytes(of: numChannels.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: sampleRateInt.littleEndian) { Array($0) })
        let byteRate: UInt32 = sampleRateInt * 2
        data.append(contentsOf: withUnsafeBytes(of: byteRate.littleEndian) { Array($0) })
        let blockAlign: UInt16 = 2
        data.append(contentsOf: withUnsafeBytes(of: blockAlign.littleEndian) { Array($0) })
        let bitsPerSample: UInt16 = 16
        data.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Array($0) })

        // data chunk
        data.append(contentsOf: "data".utf8)
        data.append(contentsOf: withUnsafeBytes(of: byteDataLen.littleEndian) { Array($0) })

        for sample in samples {
            let le = sample.littleEndian
            data.append(contentsOf: withUnsafeBytes(of: le) { Array($0) })
        }

        return data
    }
}

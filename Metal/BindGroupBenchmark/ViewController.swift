//
//  ViewController.swift
//  BindGroupBenchmark
//
//  Created by Litherum on 12/19/18.
//  Copyright © 2018 Litherum. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trials = 100000
        let maximum = 100
        let step = 1

        let device = MTLCreateSystemDefaultDevice()!

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 4, height: 4, mipmapped: false)
        var textures = [MTLTexture?](repeating: nil, count: maximum)
        for i in 0 ..< maximum {
            textures[i] = device.makeTexture(descriptor: textureDescriptor)!
        }
        
        var info = mach_timebase_info()
        mach_timebase_info(&info)
        
        for item in 1 ..< maximum / step {
            let i = item * step
            var descriptors = [MTLArgumentDescriptor]()
            for j in 0 ..< i {
                let descriptor = MTLArgumentDescriptor()
                descriptor.dataType = .texture
                descriptor.index = j
                descriptor.access = .readOnly
                descriptor.textureType = .type2D
                descriptors.append(descriptor)
            }
            let encoder = device.makeArgumentEncoder(arguments: descriptors)!

            var total = UInt64(0)
            for _ in 0 ..< trials {
                let before = mach_absolute_time()
                let buffer = device.makeBuffer(length: encoder.encodedLength, options: .storageModeShared)!
                encoder.setArgumentBuffer(buffer, offset: 0)
                for j in 0 ..< i {
                    encoder.setTexture(textures[j], index: j)
                }
                let after = mach_absolute_time()
                total += after - before;
            }
            print("\(i): \((Double(total) / Double(trials)) * Double(info.numer) / Double(info.denom) / 1000000) milliseconds")
        }
    }


}


#!/usr/bin/env python3
#-*- coding: utf-8 -*-

import sys

from libvncclient import RFBClient


class RFBPPMWriter(object):
    def __init__(self, args):
        self.written = False
        # bitsPerSample, samplesPerPixel, bytesPerPixel
        self.client = RFBClient(8, 3, 4)
        self.client.set_finished_framebuffer_update_callback(self.write_ppm)
        self.client.init_client(args)
        while not self.written:
            msg = self.client.wait_for_message(100000)
            if msg:
                self.client.handle_server_message()

    def write_ppm(self, client, fname="vnc-screenshot.ppm"):
        print('Writing the framebuffer to %s' % fname)
        f = open(fname, "wb")
        f.write(bytes("P6\n# %s\n%d %d\n255\n" % 
                                                (self.client.desktop_name, 
                                                self.client.width, 
                                                self.client.height), "UTF-8"))
        framebuffer = self.client.get_framebuffer()
        # Skip the alpha channel byte (every 4th byte). PPM does not support alpha
        for i in range(0, len(framebuffer), 4):
            f.write(framebuffer[i:i+3])
        f.close()
        self.written = True

RFBPPMWriter(sys.argv)


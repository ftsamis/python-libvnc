#!/usr/bin/env python3
#-*- coding: utf-8 -*-

import sys

from libvncclient import RFBClient


class RFBPPMWriter(object):
    def __init__(self):
        # bitsPerSample, samplesPerPixel, bytesPerPixel
        self.client = RFBClient(8, 3, 4)
        self.client.set_finished_framebuffer_update_callback(self.write_ppm)
        self.client.init_client([])
        while True:
            print('loop')
            if not self.update():
                break

    def write_ppm(self, fname="vnc-screenshot.ppm"):
        print('Writing the framebuffer to %s' % fname)
        f = open(fname, "wb")
        f.write(bytes("P6\n# %s\n%d %d\n255\n" % 
                                                (self.client.desktop_name, 
                                                self.client.width, 
                                                self.client.height), "UTF-8"))
        framebuffer = self.client.get_framebuffer()
        for i in range(0, len(framebuffer), 4):
            f.write(framebuffer[i:i+3])
        f.close()
        sys.exit(0)
    
    def update(self):
        msg = self.client.wait_for_message(50)
        handle = self.client.handle_server_message()
        return msg >= 0 and handle


RFBPPMWriter()


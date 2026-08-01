include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FreeFireHackDemo

FreeFireHackDemo_FILES = Tweak.xm
FreeFireHackDemo_CFLAGS = -fobjc-arc
FreeFireHackDemo_FRAMEWORKS = UIKit CoreGraphics
FreeFireHackDemo_LDFLAGS = -lz -lsubstrate

ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS_MAKE_PATH)/tweak.mk

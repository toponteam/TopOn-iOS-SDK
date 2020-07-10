#!/usr/bin/env python
# -*- coding:utf-8 -*-

import subprocess
import os

# 执行流程说明：
# 1、xcodebuild执行生成指定的target
# 2、copy target到指定目录
# 3、copy文档到指定目录
# 4、打成zip包 

#configuration for iOS build setting
AnyThink_VERSION = "5.5.9"
CONFIGURATION = "Release"
EXPORT_OPTIONS_PLIST = "exportOptions.plist"
# 保存发布包的路径
EXPORT_RELEASE_DIRECTORY = "../release/"
# 保存framework的路径
EXPORT_RELEASE_FRAMEWORKS_DIRECTORY = "../release/frameworks_tmp/"
# target list
EXPORT_TARGETS_LIST = ['AnyThinkSDK'
                       , 'AnyThinkNative'
                       , 'AnyThinkRewardedVideo'
                       , 'AnyThinkBanner'
                       , 'AnyThinkInterstitial'
                       , 'AnyThinkSplash'
                       # Header Bidding
                       , 'AnyThinkHeaderBidding'
                       # My Offer
                       ,'AnyThinkMyOffer'
                       # Native Adapters
                       , 'AnyThinkGDTNativeAdapter'
                       , 'AnyThinkMopubNativeAdapter'
                       , 'AnyThinkFlurryNativeAdapter'
                       , 'AnyThinkAdmobNativeAdapter'
                       , 'AnyThinkFacebookNativeAdapter'
                       , 'AnyThinkInmobiNativeAdapter'
                       , 'AnyThinkApplovinNativeAdapter'
                       , 'AnyThinkMintegralNativeAdapter'
                       , 'AnyThinkYeahmobiNativeAdapter'
                       , 'AnyThinkAppnextNativeAdapter'
#                       , 'AnyThinkMobPowerNativeAdapter'
                       , 'AnyThinkTTNativeAdapter'
                       , 'AnyThinkNendNativeAdapter'
                       , 'AnyThinkBaiduNativeAdapter'
                       , 'AnyThinkKSNativeAdapter'
                       # Rewarded Video Adapters
                       , 'AnyThinkOnewayRewardedVideoAdapter'
                       , 'AnyThinkKSRewardedVideoAdapter'
                       , 'AnyThinkTTRewardedVideoAdapter'
                       , 'AnyThinkFacebookRewardedVideoAdapter'
                       , 'AnyThinkTapjoyRewardedVideoAdapter'
                       , 'AnyThinkChartboostRewardedVideoAdapter'
                       , 'AnyThinkMopubRewardedVideoAdapter'
                       , 'AnyThinkGDTRewardedVideoAdapter'
                       , 'AnyThinkAdmobRewardedVideoAdapter'
                       , 'AnyThinkMintegralRewardedVideoAdapter'
                       , 'AnyThinkFlurryRewardedVideoAdapter'
                       , 'AnyThinkApplovinRewardedVideoAdapter'
                       , 'AnyThinkVungleRewardedVideoAdapter'
                       , 'AnyThinkIronSourceRewardedVideoAdapter'
                       , 'AnyThinkInmobiRewardedVideoAdapter'
                       , 'AnyThinkAdColonyRewardedVideoAdapter'
                       , 'AnyThinkUnityAdsRewardedVideoAdapter'
                       , 'AnyThinkYeahmobiRewardedVideoAdapter'
                       , 'AnyThinkAppnextRewardedVideoAdapter'
                       , 'AnyThinkBaiduRewardedVideoAdapter'
                       , 'AnyThinkNendRewardedVideoAdapter'
                       , 'AnyThinkMaioRewardedVideoAdapter'
                       , 'AnyThinkSigmobRewardedVideoAdapter'
                       , 'AnyThinkMyOfferRewardedVideoAdapter'
                       , 'AnyThinkOguryRewardedVideoAdapter'
                       , 'AnyThinkStartAppRewardedVideoAdapter'
                       , 'AnyThinkFyberRewardedVideoAdapter'
                       # Banner Adapters
                       , 'AnyThinkInmobiBannerAdapter'
                       , 'AnyThinkFlurryBannerAdapter'
                       ,'AnyThinkMintegralBannerAdapter'
                       , 'AnyThinkMopubBannerAdapter'
                       , 'AnyThinkFacebookBannerAdapter'
                       , 'AnyThinkApplovinBannerAdapter'
                       , 'AnyThinkGDTBannerAdapter'
                       , 'AnyThinkAdmobBannerAdapter'
                       , 'AnyThinkTTBannerAdapter'
                       , 'AnyThinkYeahmobiBannerAdapter'
                       , 'AnyThinkAppnextBannerAdapter'
                       , 'AnyThinkBaiduBannerAdapter'
                       , 'AnyThinkNendBannerAdapter'
                       , 'AnyThinkFyberBannerAdapter'
                       ,'AnyThinkStartAppBannerAdapter'
                       ,'AnyThinkVungleBannerAdapter'
                       ,'AnyThinkAdColonyBannerAdapter'
                       ,'AnyThinkChartboostBannerAdapter'
                       # Interstitial Adapters
                       , 'AnyThinkAdColonyInterstitialAdapter'
                       , 'AnyThinkKSInterstitialAdapter'
                       , 'AnyThinkVungleInterstitialAdapter'
                       , 'AnyThinkIronSourceInterstitialAdapter'
                       , 'AnyThinkTapjoyInterstitialAdapter'
                       , 'AnyThinkChartboostInterstitialAdapter'
                       , 'AnyThinkMopubInterstitialAdapter'
                       , 'AnyThinkFlurryInterstitialAdapter'
                       , 'AnyThinkInmobiInterstitialAdapter'
                       , 'AnyThinkOnewayInterstitialAdapter'
                       , 'AnyThinkFacebookInterstitialAdapter'
                       , 'AnyThinkApplovinInterstitialAdapter'
                       , 'AnyThinkMintegralInterstitialAdapter'
                       , 'AnyThinkAdmobInterstitialAdapter'
                       , 'AnyThinkTTInterstitialAdapter'
                       , 'AnyThinkGDTInterstitialAdapter'
                       , 'AnyThinkYeahmobiInterstitialAdapter'
                       , 'AnyThinkAppnextInterstitialAdapter'
                       , 'AnyThinkBaiduInterstitialAdapter'
                       , 'AnyThinkUnityAdsInterstitialAdapter'
                       , 'AnyThinkMaioInterstitialAdapter'
                       , 'AnyThinkNendInterstitialAdapter'
                       , 'AnyThinkSigmobInterstitialAdapter'
                       , 'AnyThinkMyOfferInterstitialAdapter'
                       , 'AnyThinkOguryInterstitialAdapter'
                       , 'AnyThinkStartAppInterstitialAdapter'
                       , 'AnyThinkFyberInterstitialAdapter'
                       # Splash Adapters
                       , 'AnyThinkBaiduSplashAdapter'
                       , 'AnyThinkGDTSplashAdapter'
                       , 'AnyThinkTTSplashAdapter'
                       , 'AnyThinkSigmobSplashAdapter'
                       ,'AnyThinkMintegralSplashAdapter'
                       #TraminiSDK
                       ,'TraminiSDK']
#EXPORT_TARGETS_LIST = ['AnyThinkSDK']

# CPU支持指令集架构
#EXPORT_ARCH_LIST = ['armv7','armv7s','arm64','x86_64']
EXPORT_OS_ARCH_LIST = ['armv7', 'armv7s', 'arm64']
EXPORT_SIMULATOR_ARCH_LIST = ['i386', 'x86_64']

# 编译target


def buildSDKTarget(archType):

    # 重新执行build MACH_O_TYPE=staticlib
    exportCmd = "sudo xcodebuild only_active_arch=no defines_module=yes SKIP_INSTALL=YES CODE_SIGNING_REQUIRED=NO -project AnyThinkSDK.xcodeproj clean build"
    for target in EXPORT_TARGETS_LIST:
        exportCmd = exportCmd + " -target " + target

    if archType == 1:
        # 清理之前build的内容
        #        print "clean last build begin..."
        #        cleanCmd = "xcodebuild clean  -project AnyThinkSDK.xcodeproj -sdk iphoneos -configuration " + CONFIGURATION
        #        process = subprocess.Popen(cleanCmd, shell = True)
        #        process.wait()
        #
        cleanCmd = "rm -r build/Release-iphoneos/"
        process = subprocess.Popen(cleanCmd, shell=True)
        process.wait()
        print "clean last build end..."

        for arch in EXPORT_OS_ARCH_LIST:
            exportCmd = exportCmd + " -arch " + arch

        exportCmd = exportCmd + " -sdk iphoneos"
    else:
        # 清理之前build的内容
        #        print "clean last build begin..."
        #        cleanCmd = "xcodebuild clean  -project AnyThinkSDK.xcodeproj -sdk iphonesimulator"
        #        process = subprocess.Popen(cleanCmd, shell = True)
        #        process.wait()

        cleanCmd = "rm -r build/Release-iphonesimulator/"
        process = subprocess.Popen(cleanCmd, shell=True)
        process.wait()
        print "clean last build end..."

        for arch in EXPORT_SIMULATOR_ARCH_LIST:
            exportCmd = exportCmd + " -arch " + arch

        exportCmd = exportCmd + " -sdk iphonesimulator"


#-destination generic/platform=iOS
    print "build target begin..."
    process = subprocess.Popen(exportCmd, shell=True)
    (stdoutdata, stderrdata) = process.communicate()

    signReturnCode = process.returncode
    if signReturnCode != 0:
        print "build target failed..."
        print "cmd:" + exportCmd
    else:
        print "build target end..."


# 删除旧版生成文件
def cleanLastReleaseFile():
    cleanCmd = "rm -r " + EXPORT_RELEASE_DIRECTORY + "*"
    process = subprocess.Popen(cleanCmd, shell=True)
    process.wait()
    cleanCmd = "rm -r " + EXPORT_RELEASE_FRAMEWORKS_DIRECTORY + "*"
    process = subprocess.Popen(cleanCmd, shell=True)
    process.wait()

    mkdirCmd = "mkdir " + EXPORT_RELEASE_DIRECTORY
    process = subprocess.Popen(mkdirCmd, shell=True)
    process.wait()
    print "cleaned last release files success"

# copy frameworks


def copyFrameworks(archType):
    print "copyFrameworks begin..."
    mkdirCmd = "mkdir " + EXPORT_RELEASE_FRAMEWORKS_DIRECTORY
    process = subprocess.Popen(mkdirCmd, shell=True)
    process.wait()
    export_release_frameworkds_dir = EXPORT_RELEASE_FRAMEWORKS_DIRECTORY
    if archType == 1:
        export_release_frameworkds_dir = export_release_frameworkds_dir + "os/"
    else:
        export_release_frameworkds_dir = export_release_frameworkds_dir + "simulator/"

    mkdirCmd = "mkdir " + export_release_frameworkds_dir
    process = subprocess.Popen(mkdirCmd, shell=True)
    process.wait()

    for target in EXPORT_TARGETS_LIST:
        copyCmd = ""
        if archType == 1:
            copyCmd = "cp -r build/" + CONFIGURATION + "-iphoneos/" + \
                target + ".framework " + export_release_frameworkds_dir
        else:
            copyCmd = "cp -r build/" + CONFIGURATION + "-iphonesimulator/" + \
                target + ".framework " + export_release_frameworkds_dir
        process = subprocess.Popen(copyCmd, shell=True)
        process.wait()
    print "copyFrameworks end..."

# mergeframeworks


def mergeArchFrameworks():

    export_os_frameworkds_dir = EXPORT_RELEASE_FRAMEWORKS_DIRECTORY + "os/"
    export_simulator_frameworkds_dir = EXPORT_RELEASE_FRAMEWORKS_DIRECTORY + "simulator/"
    export_merge_frameworkds_dir = EXPORT_RELEASE_FRAMEWORKS_DIRECTORY + "merge/"

    mkdirCmd = "mkdir " + export_merge_frameworkds_dir
    process = subprocess.Popen(mkdirCmd, shell=True)
    process.wait()

    # lipo merge target
    for target in EXPORT_TARGETS_LIST:
        # copy framwork
        copyCmd = "cp -r " + export_os_frameworkds_dir + \
            target + ".framework " + export_merge_frameworkds_dir
        process = subprocess.Popen(copyCmd, shell=True)
        process.wait()
        # merge arch
        exportCmd = "lipo -output " + export_merge_frameworkds_dir + target + ".framework/" + target + " -create " + \
            export_os_frameworkds_dir + target + ".framework/" + target + " " + \
            export_simulator_frameworkds_dir + target + ".framework/" + target
        process = subprocess.Popen(exportCmd, shell=True)
        process.wait()
    # update framework files import
    # updateFileContent(export_merge_frameworkds_dir + "AnyThinkNative.framework/Headers/ATNativeADDelegate.h", "#import \"ATAdLoadingDelegate.h\"", "@import AnyThinkSDK;")
    # updateFileContent(export_merge_frameworkds_dir +
    # "AnyThinkRewardedVideo.framework/Headers/ATRewardedVideoDelegate.h",
    # "#import \"ATAdLoadingDelegate.h\"", "@import AnyThinkSDK;")

    # delete exclude files from framework
#    deleteCmd = "rm " + export_merge_frameworkds_dir + "AnyThinkSDK.framework/check_build_files.py"
#    process = subprocess.Popen(deleteCmd, shell = True)
#    process.wait()
#
#    deleteCmd = "rm " + export_merge_frameworkds_dir + "AnyThinkSDK.framework/Assets.car"
#    process = subprocess.Popen(deleteCmd, shell = True)
#    process.wait()

# 修改文件内容


def updateFileContent(filePath, contentOld, contentNew):
    file_data = ""
    with open(filePath, 'r') as r:
        lines = r.readlines()
    with open(filePath, 'w') as w:
        for l in lines:
            w.write(l.replace(contentOld, contentNew))

# 生成发布zip包: ../release/201612280808

def copyBundle():
    print "copyBundle begin..."
    copyCmd = "sudo -S chmod 777 AnyThinkSDK.bundle"
    copyCmd = "cp -r AnyThinkSDK.bundle ../release/frameworks/"

    process = subprocess.Popen(copyCmd, shell=True)
    process.wait()
    print "copyBundle end..."

def buildReleaseZipFile():
    dateCmd = 'date "+%Y%m%d%H%M"'
    process = subprocess.Popen(dateCmd, stdout=subprocess.PIPE, shell=True)
    (stdoutdata, stderrdata) = process.communicate()
    currentTime = "%s" % (stdoutdata.strip())

    export_merge_frameworkds_dir = EXPORT_RELEASE_FRAMEWORKS_DIRECTORY + "merge"
    export_release_frameworks_dir = EXPORT_RELEASE_DIRECTORY + "frameworks/"

    mkdirCmd = "mkdir " + export_release_frameworks_dir
    process = subprocess.Popen(mkdirCmd, shell=True)
    process.wait()

    copyCmd = "cp -r " + export_merge_frameworkds_dir + \
        "/* " + export_release_frameworks_dir
    process = subprocess.Popen(copyCmd, shell=True)
    process.wait()

    copyBundle()

    exportZipFile = "AnyThink_SDK_IOS_" + AnyThink_VERSION + "_" + currentTime + ".zip"
    zipCmd = "zip -r %s%s %s" % (EXPORT_RELEASE_DIRECTORY,
                                 exportZipFile, export_release_frameworks_dir)
    process = subprocess.Popen(zipCmd, shell=True)
    process.wait()
    print "buildReleaseZipFile success, file:" + exportZipFile


def main():
    cleanLastReleaseFile()
    # 1:os arch,2:simulator arch
    buildSDKTarget(1)
    copyFrameworks(1)
    buildSDKTarget(2)
    copyFrameworks(2)
    mergeArchFrameworks()
    buildReleaseZipFile()


if __name__ == '__main__':
    main()

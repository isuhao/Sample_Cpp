//
//  Ads.m
//  sample
//
//  Created by cocos2dx on 14-11-10.
//  Copyright (c) 2014年 cocos2dx. All rights reserved.
//

#import "Ads.h"
#ifndef AS_NO_USING_CPP11
#include <functional>
#endif

void adsCallback(int code,string msg)
{
    printf("adsCallback %d,%s",code,msg.c_str());
    switch(code)
    {
        case kAdsReceived://广告接受成功回调
            
            break;
        case kAdsShown://广告展示回调
            
            break;
        case kAdsDismissed://广告消失回调
            
            break;
        case kPointsSpendSucceed://积分设置成功回调
            
            break;
        case kPointsSpendFailed://积分设置失败回调
            
            break;
        case kNetworkError://网络错误回调
            
            break;
        case kUnknownError://未知错误回调
            
            break;
        case kOfferWallOnPointsChanged://积分改变回调
            
            break;
        default:
            break;
    }
    
}

Ads* Ads::_pInstance = NULL;

Ads::Ads()
{
}

Ads::~Ads()
{
    
}

Ads* Ads::getInstance()
{
    if (_pInstance == NULL) {
        _pInstance = new Ads();
        _pInstance->ads_plugin = AgentManager::getInstance()->getAdsPlugin();
        _pInstance->ads_plugin->setAdsListener(_pInstance);
#ifndef AS_NO_USING_CPP11
        _pInstance->ads_plugin->setCallback(adsCallback);
#endif
        
        
    }
    return _pInstance;
}

void Ads::purge()
{
    if (_pInstance)
    {
        delete _pInstance;
        _pInstance = NULL;
    }
}
void Ads::onAdsResult(AdsResultCode code, const char* msg)
{
    NSLog(@"Ads, onAdsResult: %d, msg:%s", code, msg);
    switch(code)
    {
        case kAdsReceived://广告接受成功回调
            
            break;
        case kAdsShown://广告展示回调
            
            break;
        case kAdsDismissed://广告消失回调
            
            break;
        case kPointsSpendSucceed://积分设置成功回调
            
            break;
        case kPointsSpendFailed://积分设置失败回调
            
            break;
        case kNetworkError://网络错误回调
            
            break;
        case kUnknownError://未知错误回调
            
            break;
        case kOfferWallOnPointsChanged://积分改变回调
            
            break;
        default:
            break;
    }
}

void onPlayerGetPoints(ProtocolAds* pAdsPlugin, int points) {
    printf("points:%d\n", points);
}

void Ads::showAds(AdsType type, int idx)
{
    if(ads_plugin != nil)
    {
        if(ads_plugin->isAdTypeSupported(type))
        {
            ads_plugin->showAds(type,idx);
            
        }
    }
}

void Ads::hideAds(AdsType type, int idx)
{
    if(ads_plugin != nil)
    {
        if(ads_plugin->isAdTypeSupported(AD_TYPE_BANNER))
        {
            ads_plugin->hideAds(AD_TYPE_BANNER,idx);
        }
        
    }
}

void Ads::preloadAds(AdsType type, int idx)
{
    if(ads_plugin != nil)
    {
        if(ads_plugin->isAdTypeSupported(AD_TYPE_BANNER))
        {
            ads_plugin->preloadAds(AD_TYPE_BANNER, idx);
        }
        
    }
}

//查询积分
float Ads::queryPoints()
{
    if (ads_plugin != nil) {
        return ads_plugin->queryPoints();
    }
    return 0.0f;
}

//消费积分
void Ads::spendPoints(int points)
{
    if (ads_plugin != nil) {
        ads_plugin->spendPoints(points);
    }
}


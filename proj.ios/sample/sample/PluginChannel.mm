//
//  PluginChannel.m
//  sample
//
//  Created by cocos2dx on 14-11-10.
//  Copyright (c) 2014年 cocos2dx. All rights reserved.
//



#include "PluginChannel.h"
#include <stdlib.h>
#include "Analytics.h"
#include "Push.h"
#ifndef AS_NO_USING_CPP11
#include <functional>
#endif

#include "PartViews.h"

using namespace anysdk::framework;

#define  LOG_TAG    "PluginChannel"

void CCMessageBox(const char* content, const char* title)
{
    ////
    [PartViews addDebugView:[[NSString alloc] initWithUTF8String:title] ctx:[[NSString alloc] initWithUTF8String:content]];
}

void CCExit()
{
    ////
    exit(0);
}

void ShowTipDialog()
{
    ////
}

void userCallback(int code,string msg)
{
    printf("userCallback %d,%s",code,msg.c_str());
    bool _userLogined = false;
    switch(code)
    {
        case kInitSuccess://初始化SDK成功回调
            break;
        case kInitFail://初始化SDK失败回调
            CCExit();
            break;
        case kLoginSuccess://登陆成功回调
            _userLogined = true;
            //            CCMessageBox(msg, "User is  online");
            CCMessageBox("Success!", "Login");
            if (PluginChannel::getInstance()->getChannelId() == "000255") {//UC渠道
                printf("开始调用submitLoginGameRole函数\n");
                PluginChannel::getInstance()->submitLoginGameRole();
                printf("结束调用submitLoginGameRole函数\n");
            }
            break;
        case kLoginNoNeed:  //不需要登陆
        case kLoginNetworkError://登陆失败回调
        case kLoginCancel://登陆取消回调
        case kLoginFail://登陆失败回调
            CCMessageBox(msg.c_str(), "login");
            _userLogined = false;
            Analytics::getInstance()->logError("login","fail");
            break;
        case kLogoutSuccess://登出成功回调
        case kLogoutFail://登出失败回调
            CCMessageBox(msg.c_str()  , "Logout");
            break;
        case kPlatformEnter://平台中心进入回调
            break;
        case kPlatformBack://平台中心退出回调
            break;
        case kPausePage://暂停界面回调
            break;
        case kExitPage://退出游戏回调
            CCExit();
            
            break;
        case kAntiAddictionQuery://防沉迷查询回调
            CCMessageBox(msg.c_str()  , "防沉迷查询回调");
            break;
        case kRealNameRegister://实名注册回调
            CCMessageBox(msg.c_str()  , "实名注册回调");
            break;
        case kAccountSwitchSuccess://切换账号成功回调
            break;
        case kAccountSwitchFail://切换账号成功回调
            break;
        default:
            break;
    }
}

void iapCallback(int code,string msg)
{
    printf("iapCallback %d,%s",code,msg.c_str());
    std::string temp = "fail";
    switch(code)
    {
        case kPaySuccess://支付成功回调
            temp = "Success";
            CCMessageBox(temp.c_str() , temp.c_str() );
            break;
        case kPayFail://支付失败回调
            CCMessageBox(temp.c_str()  , temp.c_str() );
            break;
        case kPayCancel://支付取消回调
            CCMessageBox(temp.c_str()  , "Cancel" );
            break;
        case kPayNetworkError://支付超时回调
            CCMessageBox(temp.c_str()  , "NetworkError");
            break;
        case kPayProductionInforIncomplete://支付超时回调
            CCMessageBox(temp.c_str()  , "ProductionInforIncomplete");
            break;
            /**
             * 新增加:正在进行中回调
             * 支付过程中若SDK没有回调结果，就认为支付正在进行中
             * 游戏开发商可让玩家去判断是否需要等待，若不等待则进行下一次的支付
             */
        case kPayNowPaying:
            ShowTipDialog();
            break;
        default:
            break;
    }
    
    
}


PluginChannel* PluginChannel::_pInstance = NULL;
static AllProductsInfo _myProducts;

PluginChannel::PluginChannel()
{
    _pluginsIAPMap = NULL;
    _iapCount = 0;
}

PluginChannel::~PluginChannel()
{
    unloadPlugins();
}

PluginChannel* PluginChannel::getInstance()
{
    if (_pInstance == NULL) {
        _pInstance = new PluginChannel();
    }
    return _pInstance;
}

void PluginChannel::purge()
{
    if (_pInstance)
    {
        delete _pInstance;
        _pInstance = NULL;
    }
}

//使用game.com的时候注释掉这个宏就可以
//#define isQudaoInfo 1
void PluginChannel::loadPlugins()
{
    printf("Load plugins invoked\n");
    /**
     * appKey、appSecret、privateKey不能使用Sample中的值，需要从打包工具中游戏管理界面获取，替换
     * oauthLoginServer参数是游戏服务提供的用来做登陆验证转发的接口地址。
     */
#define qudao_info
#ifdef qudao_info
    std::string appKey = "0914CB16-BAEE-790E-808E-3A37B8FFBE3F";
    std::string appSecret = "62bee0ddb86bdeccb8acd959765041cc";
    std::string privateKey = "96C273AB03E1A798BA1AD0C38004871F";
    std::string oauthLoginServer = "http://oauth.qudao.info/api/OauthLoginDemo/Login.php";
#else
    std::string appKey = "CED525C0-8D41-F514-96D8-90092EB3899A";
    std::string appSecret = "a29b4f22aa63b8274f7f6e2dd5893d9b";
    std::string privateKey = "963C4B4DA71BC51C69EB11D24D0C7D49";
    std::string oauthLoginServer = "http://oauth.anysdk.com/api/OauthLoginDemo/Login.php";
#endif
    _pAgent = AgentManager::getInstance();
    _pAgent->init(appKey,appSecret,privateKey,oauthLoginServer);
    
    //使用框架中代理类进行插件初始化
    _pAgent->loadAllPlugins();
    
    _pUser = _pUser;
    
    //对用户系统设置监听类
    if(_pUser)
    {
#ifndef AS_NO_USING_CPP11
        _pUser->setCallback(userCallback);
        _pAgent->getCustomPlugin()->setCallback(userCallback);
#endif
    }
    
    //对支付系统设置监听类
    _pluginsIAPMap  = _pAgent->getIAPPlugin();
    _iapCount = _pluginsIAPMap->size();
    std::map<std::string , ProtocolIAP*>::iterator iter;
    for(iter = _pluginsIAPMap->begin(); iter != _pluginsIAPMap->end(); iter++)
    {
        (iter->second)->setResultListener(this);
#ifndef AS_NO_USING_CPP11
        (iter->second)->setCallback(iapCallback);
#endif
    }
    
    Analytics::getInstance()->setCaptureUncaughtException(true);
    Analytics::getInstance()->setSessionContinueMillis(15000);
    Analytics::getInstance()->logTimedEventBegin("Load");
    Push::getInstance()->startPush();
    
    _iapIPhone = getIAPIphone();
}

void PluginChannel::unloadPlugins()
{
    printf("Unload plugins invoked\n");
    _pAgent->unloadAllPlugins();
    Analytics::getInstance()->logTimedEventEnd("Unload");
}

std::string PluginChannel::getPluginId()
{
    if(_pUser)
    {
        return _pUser->getPluginId();
    }
    return "";
}

void PluginChannel::login()
{
    if(_pUser)
    {
        _pUser->login();
        Analytics::getInstance()->logEvent("login");
    }
}


void PluginChannel::logout()
{
    if(_pUser)
    {
        if(isFunctionSupported("logout"))
        {
            
            _pUser->callFuncWithParam("logout",NULL);
        }
    }
}

bool PluginChannel::isFunctionSupported(std::string strClassName)
{
    if(_pUser)
    {
        return _pUser->isFunctionSupported(strClassName);
        
    }
    return false;
}

const char* PluginChannel::getResourceId(std::string name)
{
    printf("getResourceId:%s\n", name.c_str());
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"channel" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    NSString* key = [[NSString alloc] initWithUTF8String:name.c_str()];
    NSString* value = [data objectForKey:key];
    return [value UTF8String];
}

void PluginChannel::ChoosePayMode(std::vector<std::string>& pluginId)
{
    NSMutableDictionary* _list = [NSMutableDictionary dictionary];
    ////display interface
    std::vector<std::string>::iterator iter;
    for (iter = pluginId.begin(); iter != pluginId.end(); iter++) {
        printf("channelID:%s\n", (*iter).c_str());
        std::string key = "Channel" + (*iter);
        NSString* channelName = [[NSString alloc] initWithUTF8String:getResourceId(key)];
        NSString* channelKey = [[NSString alloc] initWithUTF8String:(*iter).c_str()];
        [_list setObject:channelName forKey:channelKey];
    }
    [PartViews addButtons:_list];
}

void PluginChannel::payMode(std::string id)
{
    std::map<std::string , ProtocolIAP*>::iterator iter;
    iter = _pluginsIAPMap->find(id);
    if(iter != _pluginsIAPMap->end())
    {
        if (iter->first == IAP_IPHONE_ID) {
            (iter->second)->payForProduct(_myProducts["2"]);
        }
        else{
            (iter->second)->payForProduct(productInfo);
        }
    }
}

ProtocolIAP* PluginChannel::getIAPIphone()
{
    if(_pluginsIAPMap)
    {
        std::map<std::string , ProtocolIAP*>::iterator it = _pluginsIAPMap->begin();
        for (; it != _pluginsIAPMap->end(); it++) {
            if (it->first == IAP_IPHONE_ID) {
                return it->second;
            }
        }
    }
    return NULL;
}

void PluginChannel::requestProducts()
{
    printf("payRequest\n");
    if ( NULL!= _iapIPhone ) {
        PluginParam param1("PD_10005");
        PluginParam param2("PD_10004");
        PluginParam param3("PD_10003");
        _iapIPhone->callFuncWithParam("requestProducts", &param1, &param2, &param3, NULL);
    }
    else{
        printf("iap iphone isn't find!\n");
    }
}

void PluginChannel::pay()
{
    if ( NULL != _iapIPhone && _iapCount == 1) {
        if (_myProducts.size() > 0) {
            _iapIPhone->payForProduct(_myProducts["1"]);
        }
        else{
            printf("product info is null, please request products info.\n");
        }
        return;
    }
    
    std::map<std::string , ProtocolIAP*>::iterator it = _pluginsIAPMap->begin();
    if(_pluginsIAPMap)
    {
        productInfo["Product_Price"] = "1";
        if(_pAgent->getChannelId()=="000016" || _pAgent->getChannelId()=="000009"|| _pAgent->getChannelId()=="000349"){
            productInfo["Product_Id"] = "1";
        }
        else
            if(_pAgent->getChannelId()=="000056" ){//联通，传计费点
                productInfo["Product_Id"] = "130201102727";
            }
            else
                if (_pAgent->getChannelId()=="000266") {//移动基地，传计费点后三位
                    productInfo["Product_Id"] = "001";
                }
                else
                {
                    productInfo["Product_Id"] = "monthly";
                }
        
        productInfo["Product_Name"] = "豌豆荚测试a1";
        productInfo["Server_Id"] = "13";
        productInfo["Product_Count"] = "1";
        productInfo["Role_Id"] = "1";
        productInfo["Role_Name"] = "1";
        productInfo["Role_Grade"] = "1";
        productInfo["Role_Balance"] = "1";
        Analytics::getInstance()->logEvent("pay", productInfo);
        if(_pluginsIAPMap->size() == 1)
        {
            (it->second)->payForProduct(productInfo);
        }
        else if(_pluginsIAPMap->size() > 1)
        {
            std::vector<std::string> pluginId;
            for (;it != _pluginsIAPMap->end();++it)
            {
                pluginId.push_back(it->first);
            }
            ChoosePayMode(pluginId);
        }
    }
    
    
    PluginParam param3("size");
    std::vector<PluginParam*> params;
    params.push_back(&param3);
}

void PluginChannel::resetPayState()
{
    ProtocolIAP::resetPayState();
    pay();
}

std::string PluginChannel::getUserId()
{
    if(_pUser)
    {
        return _pUser->getUserID();
    }
    return "";
}

void PluginChannel::enterPlatform()
{
    if(_pUser)
    {
        //使用isFunctionSupported可先判断该插件是否支持该功能
        if(isFunctionSupported("enterPlatform"))
        {
            _pUser->callFuncWithParam("enterPlatform",NULL);
        }
    }
}

void PluginChannel::showToolBar(ToolBarPlace place)
{
    if(_pUser)
    {
        if(isFunctionSupported("showToolBar"))
        {
            PluginParam paramInfo(place);
            _pUser->callFuncWithParam("showToolBar",&paramInfo,NULL);
        }
    }
}

void PluginChannel::hideToolBar()
{
    if(_pUser)
    {
        if(isFunctionSupported("hideToolBar"))
        {
            _pUser->callFuncWithParam("hideToolBar",NULL);
        }
    }
}

void PluginChannel::pause()
{
    if(_pUser)
    {
        if(isFunctionSupported("pause"))
        {
            _pUser->callFuncWithParam("pause",NULL);
        }
    }
}

void PluginChannel::destroy()
{
    if(_pUser)
    {
        if(isFunctionSupported("destroy"))
        {
            _pUser->callFuncWithParam("destroy",NULL);
        }
    }
}

void PluginChannel::Exit()
{
    if(_pUser)
    {
        if(isFunctionSupported("exit"))
        {
            _pUser->callFuncWithParam("exit",NULL);
        }
        
    }
}

void PluginChannel::antiAddictionQuery()
{
    if(_pUser)
    {
        if(isFunctionSupported("antiAddictionQuery"))
        {
            _pUser->callFuncWithParam("antiAddictionQuery",NULL);
        }
        
    }
}

void PluginChannel::accountSwitch()
{
    if(_pUser)
    {
        if(isFunctionSupported("accountSwitch"))
        {
            _pUser->callFuncWithParam("accountSwitch",NULL);
        }
        
    }
}

void PluginChannel::realNameRegister()
{
    if(_pUser)
    {
        if(isFunctionSupported("realNameRegister"))
        {
            _pUser->callFuncWithParam("realNameRegister",NULL);
        }
        
    }
}

void PluginChannel::submitLoginGameRole()
{
    if(_pUser)
    {
        if(PluginChannel::getInstance()->isFunctionSupported("submitLoginGameRole"))
        {
            StringMap userInfo;
            userInfo["roleId"] = "ceshi : 123456";
            userInfo["roleName"] = "ceshi : test";
            userInfo["roleLevel"] = "ceshi : 10";
            userInfo["zoneId"] = "ceshi : 123";
            userInfo["zoneName"] = "ceshi : test";
            userInfo["dataType"] = "ceshi : 1";
            userInfo["ext"] = "ceshi : login";
            PluginParam data(userInfo);
            _pUser->callFuncWithParam("submitLoginGameRole",&data,NULL);
        }
    }
}



void PluginChannel::onRequestResult(RequestResultCode ret, const char* msg, AllProductsInfo info)
{
    //info: 商品获取到的信息，请在这里进行商品界面的展示。
    printf("get all iap-iphone products info:%lu\n", info.size());
    map<string,TProductInfo>::iterator iter = info.begin();
    for (iter; iter != info.end(); iter++) {
        map<string,string> item = iter->second;
        map<string,string>::iterator it = item.find("productidentify");
        if (it != item.end()) {
            productInfo["Product_Id"] = it->second;
        }
        it = item.find("price");
        if (it != item.end()) {
            productInfo["Product_Price"] = it->second;
        }
        
    }
    
}

void PluginChannel::onPayResult(PayResultCode ret, const char* msg, TProductInfo info)
{
    printf("onPayResult, %s\n", msg);
    std::string temp = "fail";
    switch(ret)
    {
        case kPaySuccess://支付成功回调
            temp = "Success";
            CCMessageBox(temp.c_str() , temp.c_str() );
            break;
        case kPayFail://支付失败回调
            CCMessageBox(temp.c_str()  , temp.c_str() );
            break;
        case kPayCancel://支付取消回调
            CCMessageBox(temp.c_str()  , "Cancel" );
            break;
        case kPayNetworkError://支付超时回调
            CCMessageBox(temp.c_str()  , "NetworkError");
            break;
        case kPayProductionInforIncomplete://支付超时回调
            CCMessageBox(temp.c_str()  , "ProductionInforIncomplete");
            break;
            /**
             * 新增加:正在进行中回调
             * 支付过程中若SDK没有回调结果，就认为支付正在进行中
             * 游戏开发商可让玩家去判断是否需要等待，若不等待则进行下一次的支付
             */
        case kPayNowPaying:
            ShowTipDialog();
            break;
        default:
            break;
    }
}

void PluginChannel::onActionResult(ProtocolUser* pPlugin, UserActionResultCode code, const char* msg)
{
    printf("PluginChannel, onActionResult:%d, msg:%s\n",code,msg);
    bool _userLogined = false;
    switch(code)
    {
        case kInitSuccess://初始化SDK成功回调
            break;
        case kInitFail://初始化SDK失败回调
            CCExit();
            break;
        case kLoginSuccess://登陆成功回调
            _userLogined = true;
//            CCMessageBox(msg, "User is  online");
            CCMessageBox("Success!", "Login");
            if (getChannelId() == "000255") {//UC渠道
                printf("开始调用submitLoginGameRole函数\n");
                submitLoginGameRole();
                printf("结束调用submitLoginGameRole函数\n");
            }
            break;
        case kLoginNoNeed:  //不需要登陆
        case kLoginNetworkError://登陆失败回调
        case kLoginCancel://登陆取消回调
        case kLoginFail://登陆失败回调
            CCMessageBox(msg, "login");
            _userLogined = false;
            Analytics::getInstance()->logError("login","fail");
            break;
        case kLogoutSuccess://登出成功回调
        case kLogoutFail://登出失败回调
            CCMessageBox(msg  , "Logout");
            break;
        case kPlatformEnter://平台中心进入回调
            break;
        case kPlatformBack://平台中心退出回调
            break;
        case kPausePage://暂停界面回调
            break;
        case kExitPage://退出游戏回调
            CCExit();
            
            break;
        case kAntiAddictionQuery://防沉迷查询回调
            CCMessageBox(msg  , "防沉迷查询回调");
            break;
        case kRealNameRegister://实名注册回调
            CCMessageBox(msg  , "实名注册回调");
            break;
        case kAccountSwitchSuccess://切换账号成功回调
            break;
        case kAccountSwitchFail://切换账号成功回调
            break;
        default:
            break;
    }
}

std::string PluginChannel::getChannelId()
{
    return _pAgent->getChannelId();
}

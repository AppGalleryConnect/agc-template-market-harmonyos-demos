package com.huawei.clouddev;

import com.huawei.agconnect.AGConnectInstance;
import com.huawei.agconnect.AGConnectOptionsBuilder;
import com.huawei.clouddev.slice.MainAbilitySlice;
import ohos.aafwk.ability.Ability;
import ohos.aafwk.content.Intent;
import ohos.global.resource.RawFileEntry;
import ohos.global.resource.Resource;
import ohos.global.resource.ResourceManager;

import java.util.UUID;

public class MainAbility extends Ability {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setMainRoute(MainAbilitySlice.class.getName());
        initComponents(intent);
    }

    private void initComponents(Intent intent) {
        try {
            AGConnectOptionsBuilder builder = new AGConnectOptionsBuilder();
            ResourceManager resourceManager = getResourceManager();
            // agconnect-services.json 文件路径
            RawFileEntry rawFileEntry =  resourceManager.getRawFileEntry("resources/rawfile/agconnect-services.json");
            Resource resource = rawFileEntry.openRawFile();
            builder.setInputStream(resource );
            // 如果您的json文件中不存在client_id、client_secret和api_key参数，需通过以下接口设置
            AGConnectInstance.initialize(getAbilityPackage(), builder);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

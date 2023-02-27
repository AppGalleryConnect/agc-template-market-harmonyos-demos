package com.huawei.clouddev.slice;

import com.huawei.agconnect.function.AGCFunctionException;
import com.huawei.agconnect.function.AGConnectFunction;
import com.huawei.agconnect.function.FunctionResult;
import com.huawei.clouddev.ResourceTable;
import com.huawei.hmf.tasks.HarmonyTask;
import com.huawei.hmf.tasks.OnHarmonyCompleteListener;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;
import ohos.agp.components.Button;
import ohos.agp.components.Text;
import ohos.agp.utils.Color;
import ohos.hiviewdfx.HiLog;
import ohos.hiviewdfx.HiLogLabel;
import ohos.utils.zson.ZSONObject;

public class CloudFunctionAbilitySlice extends AbilitySlice {
    private static final HiLogLabel LABEL = new HiLogLabel(HiLog.LOG_APP, 0, "Function");
    private AGConnectFunction function;

    private Text uuidOutput;
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_ability_cloud_function);
        initComponents();
    }

    private void initComponents() {
        findComponentById(ResourceTable.Id_generate_id).setClickedListener(component -> {
            getResult();
        });
    }

    private void getResult() {
        function = AGConnectFunction.getInstance();
        function.wrap("idgenerator-$latest").call()
                .addOnCompleteListener(new OnHarmonyCompleteListener<FunctionResult>() {
                    @Override
                    public void onComplete(HarmonyTask<FunctionResult> task) {
                        if (task.isSuccessful()) {
                            ZSONObject uuid = ZSONObject.stringToZSON(task.getResult().getValue());
                            if (uuid != null) {
                                uuidOutput = (Text) findComponentById(ResourceTable.Id_uuid);
                                uuidOutput.setText(uuid.getString("uuid"));
                            }
                        } else {
                            Exception e = task.getException();
                            if (e instanceof AGCFunctionException) {
                                AGCFunctionException functionException = (AGCFunctionException) e;
                                int errCode = functionException.getCode();
                                String message = functionException.getMessage();
                            }
                            HiLog.error(LABEL, "Get uuid error!");
                            uuidOutput = (Text) findComponentById(ResourceTable.Id_uuid);
                            uuidOutput.setText("Get uuid error!");
                        }
                    }
                });
    }
}

package org.zstack.network.service.virtualrouter.vyos;

import org.zstack.header.core.ReturnValueCompletion;
import org.zstack.network.service.virtualrouter.VirtualRouterGlobalProperty;
import org.zstack.network.service.virtualrouter.VirtualRouterStruct;
import org.zstack.network.service.virtualrouter.VirtualRouterVmInventory;
import org.zstack.network.service.virtualrouter.vip.VirtualRouterVipBackend;

/**
 * Created by xing5 on 2016/10/31.
 */
public class VyosVipBackend extends VirtualRouterVipBackend {
    @Override
    protected void acquireVirtualRouterVm(VirtualRouterStruct struct, ReturnValueCompletion<VirtualRouterVmInventory> completion) {
        struct.setApplianceVmType(VyosConstants.VYOS_VM_TYPE);
        struct.setProviderType(VyosConstants.VYOS_ROUTER_PROVIDER_TYPE);
        struct.setVirtualRouterOfferingSelector(new VyosOfferingSelector());
        struct.setApplianceVmAgentPort(VirtualRouterGlobalProperty.AGENT_PORT);
        super.acquireVirtualRouterVm(struct, completion);
    }

    @Override
    public String getServiceProviderTypeForVip() {
        return VyosConstants.VYOS_ROUTER_PROVIDER_TYPE;
    }
}

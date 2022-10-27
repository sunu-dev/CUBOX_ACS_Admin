package aero.cubox.door.service.impl;

import aero.cubox.door.service.DoorGroupService;
import aero.cubox.util.StringUtil;
import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service("doorGroupService")
public class DoorGroupServiceImpl extends EgovAbstractServiceImpl implements DoorGroupService {

    @Resource(name="doorGroupDAO")
    private DoorGroupDAO doorGroupDAO;


    /**
     * 출입문 그룹 검색
     * @param commandMap
     * @return
     */
    @Override
    public List<HashMap> getDoorGroupList(Map<String, Object> commandMap) {

        return doorGroupDAO.getDoorGroupList(commandMap);
    }

    @Override
    public int getDoorGroupListCount(Map<String, Object> commandMap) {
        return doorGroupDAO.getDoorGroupListCount(commandMap);
    }


    /**
     * 출입문 그럽 상세
     * @param id
     * @return
     */
    @Override
    public HashMap getDoorGroupDetail(int id) {
        return  doorGroupDAO.getDoorGroupDetail(id);
    }

    /**
     * 출입문 그룹 추가
     * @param commandMap
     */
    @Override
    public void addDoorGroup(Map<String, Object> commandMap) {
        doorGroupDAO.addDoorGroup(commandMap);

        String newDoorGroupId = "";
        newDoorGroupId = commandMap.get("doorgrpId").toString();

        HashMap paramMap = new HashMap();

        //출입권한-출입문 table에 door_id Insert
        if( !StringUtil.isEmpty((String) commandMap.get("doorIds"))){

            String doorIds = "";
            doorIds = commandMap.get("doorIds").toString();

            if( doorIds.length() > 0 ){
                String[] doorIdArr = doorIds.split("/");
                for (int i = 0; i < doorIdArr.length; i++) {
                    paramMap.put("doorId", doorIdArr[i]);
                    paramMap.put("doorgrpId", newDoorGroupId);

                    doorGroupDAO.addDoorInDoorGroup(paramMap);
                }
            }
        }

        doorGroupDAO.addDoorInDoorGroup(commandMap);

    }

    @Override
    public void addDoorInDoorGroup(Map<String, Object> commandMap) {
        doorGroupDAO.addDoorInDoorGroup(commandMap);
    }




    /**
     * 출입문 그룹 수정
     * @param commandMap
     */
    @Override
    public void updateDoorGroup(Map<String, Object> commandMap) {
        doorGroupDAO.updateDoorGroup(commandMap);
    }

    /**
     * 출입문 그룹 삭제
     * @param commandMap
     */
    @Override
    public void deleteDoorGroup(int commandMap) {
        doorGroupDAO.deleteDoorGroup(commandMap);
    }

    @Override
    public int getDoorGroupNameVerification(HashMap<String, Object> param) {
        return doorGroupDAO.getDoorGroupNameVerification(param);
    }


}

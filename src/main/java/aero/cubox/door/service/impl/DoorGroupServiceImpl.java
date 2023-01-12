package aero.cubox.door.service.impl;

import aero.cubox.door.service.DoorGroupService;
import aero.cubox.util.StringUtil;
import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static aero.cubox.util.StringUtil.isEmpty;

@Service("doorGroupService")
public class DoorGroupServiceImpl extends EgovAbstractServiceImpl implements DoorGroupService {

    @Resource(name="doorGroupDAO")
    private DoorGroupDAO doorGroupDAO;

    @Resource(name="doorDAO")
    private DoorDAO doorDAO;


    /**
     * 출입문 그룹 검색
     * @param commandMap
     * @return
     */
    @Override
    public List<HashMap> getSchDoorGroupList(Map<String, Object> commandMap) {

        return doorGroupDAO.getSchDoorGroupList(commandMap);
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
     *
     * @param commandMap
     * @return
     */
    @Override
    public String addDoorGroup(Map<String, Object> commandMap) {
        String newDoorGroupId = "";

        doorGroupDAO.addDoorGroup(commandMap);

        newDoorGroupId = commandMap.get("doorgrpId").toString();

        HashMap paramMap = new HashMap();

        //출입권한-출입문 table에 door_id Insert
        if( !isEmpty((String) commandMap.get("doorIds"))){

            String doorIds = "";
            doorIds = commandMap.get("doorIds").toString();

            if( doorIds.length() > 0 ){
                String[] doorIdArr = doorIds.split("/");
                for (int i = 0; i < doorIdArr.length; i++) {
                    paramMap.put("id", doorIdArr[i]);
                    paramMap.put("schDoorgrpId", newDoorGroupId);

                    doorDAO.updateDoorBySchedule(paramMap);
                }
            }
        }
        return newDoorGroupId;
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

        //HashMap originDoorGroup = doorGroupDAO.getDoorGroupDetail((Integer) commandMap.get("id"));
        doorGroupDAO.updateDoorGroup(commandMap);

        commandMap.put("schDoorgrpId", commandMap.get("id"));//서버에 저장된 스케쥴ID
        //String originDoorIds = (StringUtil.isNullToString(originDoorGroup.get("door_ids"))=="")?"":originDoorGroup.get("door_ids").toString();

        doorDAO.updateDoorByScheduleInit(commandMap);

        /*

        if( originDoorIds.length() > 0 ) {
            String[] originDoorIdArr = originDoorIds.split("/");
            commandMap.put("doorIdArr", originDoorIdArr);//서버에 저장된 스케쥴ID
            doorDAO.updateDoorByScheduleInit(commandMap);
        }
*/


        //commandMap.put("schDoorgrpId", commandMap.get("doorSchId").toString()); //클라이언트에서 전달받은 스케쥴ID

        //출입권한-출입문 table에 door_id Insert
        if( !isEmpty((String) commandMap.get("doorIds"))){

            String doorIds = "";
            doorIds = commandMap.get("doorIds").toString();

            if( doorIds.length() > 0 ){

                String[] doorIdArr = doorIds.split("/");
                for (int i = 0; i < doorIdArr.length; i++) {

                    commandMap.put("id", doorIdArr[i]);
                    doorDAO.updateDoorBySchedule(commandMap);
                }
            }
        }
    }

    /**
     * 출입문 그룹 삭제
     * @param id
     */
    @Override
    public void deleteDoorGroup(int id) {
        doorGroupDAO.deleteDoorGroup(id);
    }

    @Override
    public int getDoorGroupNameVerification(HashMap<String, Object> param) {
        return doorGroupDAO.getDoorGroupNameVerification(param);
    }


}

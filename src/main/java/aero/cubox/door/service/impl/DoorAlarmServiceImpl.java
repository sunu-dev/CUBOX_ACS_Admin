package aero.cubox.door.service.impl;

import aero.cubox.door.service.DoorAlarmService;
import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static aero.cubox.util.StringUtil.isEmpty;

@Service("doorAlarmService")
public class DoorAlarmServiceImpl extends EgovAbstractServiceImpl implements DoorAlarmService {

    @Resource(name="doorAlarmDAO")
    private DoorAlarmDAO doorAlarmDAO;



    /**
     * 출입문 알람그룹 목록 조회
     * @param commandMap
     * @return
     */
    @Override
    public List<HashMap> getDoorAlarmGrpList(Map<String, Object> paramMap) {
        return  doorAlarmDAO.getDoorAlarmGrpList(paramMap);
    }

    @Override
    public int getDoorAlarmGrpListCount(HashMap<String, Object> paramMap) {
        return doorAlarmDAO.getDoorAlarmGrpListCount(paramMap);
    }

    /**
     * 출입문 알람그룹 상세
     * @param int
     * @return
     */
    @Override
    public HashMap getDoorAlarmGrpDetail(int id) {
        return doorAlarmDAO.getDoorAlarmGrpDetail(id);
    }

    /**
     * 출입문 알람그룹 등록
     *
     * @param commandMap
     * @return
     */
    @Override
    public String addDoorAlarmGrp(Map<String, Object> commandMap) {
        String newAlarmGroupId = "";
        doorAlarmDAO.addDoorAlarmGrp(commandMap);
        newAlarmGroupId = commandMap.get("doorAlarmGrpId").toString();

        commandMap.put("dooralramGrpId", newAlarmGroupId);

        //출입권한-출입문 table에 door_id Insert
        if (!isEmpty((String) commandMap.get("doorIds"))) {

            String doorIds = "";
            doorIds = commandMap.get("doorIds").toString();

            if (doorIds.length() > 0 ) {

                String[] doorIdArr = doorIds.split("/");
                for (int i = 0; i < doorIdArr.length; i++) {
                    commandMap.put("doorId", doorIdArr[i]);
                    doorAlarmDAO.addDoorInDoorAlarmGroup(commandMap);
                }
            }
        }
        return newAlarmGroupId;
    }

    /**
     * 출입문 알람그룹 수정
     * @param commandMap
     */
    @Override
    public void updateDoorAlarmGrp(Map<String, Object> commandMap) {
        doorAlarmDAO.updateDoorAlarmGrp(commandMap);

        commandMap.put("dooralramGrpId", commandMap.get("id").toString());
        doorAlarmDAO.deleteDoorInDoorAlarmGroup(commandMap);

        //출입권한-출입문 table에 door_id Insert
        if( !isEmpty((String) commandMap.get("doorIds"))){

            String doorIds = "";
            doorIds = commandMap.get("doorIds").toString();

            if( doorIds.length() > 0 ){

                String[] doorIdArr = doorIds.split("/");
                for (int i = 0; i < doorIdArr.length; i++) {
                    commandMap.put("doorId", doorIdArr[i]);
                    doorAlarmDAO.addDoorInDoorAlarmGroup(commandMap);
                }
            }
        }

    }

    /**
     * 출입문 알람그룹 삭제
     * @param id
     */
    @Override
    public void deleteDoorAlarmGrp(int id) {
        doorAlarmDAO.deleteDoorAlarmGrp(id);
    }

    @Override
    public int getDoorAlarmGroupNameVerification(HashMap<String, Object> param) {
        return doorAlarmDAO.getDoorAlarmGroupNameVerification(param);
    }

    @Override
    public List<HashMap> getDoorAlarmTypeList() {
        return doorAlarmDAO.getDoorAlarmTypeList();
    }

    @Override
    public List<HashMap> getAlarmUseTypeList() {
        return doorAlarmDAO.getAlarmUseTypeList();
    }

}

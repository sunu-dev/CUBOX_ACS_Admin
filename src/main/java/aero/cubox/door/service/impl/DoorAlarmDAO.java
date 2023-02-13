package aero.cubox.door.service.impl;

import egovframework.rte.psl.dataaccess.EgovAbstractMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository("doorAlarmDAO")
public class DoorAlarmDAO extends EgovAbstractMapper {

    private static final String sqlNameSpace = "door.alarm.";

    public List<HashMap> getDoorAlarmGrpList(Map<String, Object> paramMap) {
        return selectList(sqlNameSpace+"selectDoorAlarmGrpList", paramMap);
    }

    public int getDoorAlarmGrpListCount(Map<String, Object> paramMap) {
        return selectOne(sqlNameSpace+"selectDoorAlarmGrpListCount", paramMap);
    }

    public HashMap getDoorAlarmGrpDetail(int id) {
        return selectOne(sqlNameSpace+"selectDoorAlarmGrpDetail", id);
    }

    public void addDoorAlarmGrp(Map<String, Object> paramMap) {
        insert(sqlNameSpace+"insertDoorAlarmGrp", paramMap);
    }

    public void updateDoorAlarmGrp(Map<String, Object> paramMap) {
        update(sqlNameSpace+"updateDoorAlarmGrp", paramMap);
    }

    public void deleteDoorAlarmGrp(int id) {
        delete(sqlNameSpace+"deleteDoorAlarmGrp", id);
    }

    public int getDoorAlarmGroupNameVerification(HashMap<String, Object> param) {
        return selectOne(sqlNameSpace+"selectDoorAlarmGrpNameVerification", param);
    }

    public void addDoorInDoorAlarmGroup(Map<String, Object> paramMap) {
        insert(sqlNameSpace+"insertDoorInDoorAlarmGroup", paramMap);
    }

    public void updateDoorInDoorAlarmGroup(Map<String, Object> paramMap) {
        update(sqlNameSpace+"updateDoorInDoorAlarmGroup", paramMap);
    }

    public void deleteDoorInDoorAlarmGroup(Map<String, Object> paramMap) {
        update(sqlNameSpace+"deleteDoorInDoorAlarmGroup", paramMap);
    }

    public List<HashMap> getDoorAlarmTypeList() {
        return selectList(sqlNameSpace+"selectDoorAlarmTypeList");
    }

    public List<HashMap> getAlarmUseTypeList() {
        return selectList(sqlNameSpace+"selectAlarmUseTypeList");
    }

    public void updateDoorAlarmGrpId(Map<String, Object> paramMap) {
        update(sqlNameSpace + "updateDoorAlarmGrpId", paramMap);
    }

    public void updateDoorAlarmGrpIdInit(Map<String, Object> paramMap) {
        update(sqlNameSpace + "updateDoorAlarmGrpIdInit", paramMap);
    }

    public void addDoorAlarmGrpId(Map<String, Object> paraMap) {
        update(sqlNameSpace + "addDoorAlarmGrpId", paraMap);
    }
}

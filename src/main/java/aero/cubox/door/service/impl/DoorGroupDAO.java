package aero.cubox.door.service.impl;

import egovframework.rte.psl.dataaccess.EgovAbstractMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository("doorGroupDAO")
public class DoorGroupDAO extends EgovAbstractMapper {

    private static final String sqlNameSpace = "door.group.";

    public List<HashMap> getSchDoorGroupList(Map<String, Object> paramMap) {
        return selectList(sqlNameSpace+"selectSchDoorGroupList", paramMap);
    }

    public int getDoorGroupListCount(Map<String, Object> paramMap) {
        return selectOne (sqlNameSpace+"selectDoorGroupListCount", paramMap);
    }


    public HashMap getDoorGroupDetail(int id) {
        return selectOne(sqlNameSpace+"selectDoorGroupDetail", id);
    }

    public void addDoorGroup(Map<String, Object> paramMap) {

        insert(sqlNameSpace+"insertDoorGroup", paramMap);
    }
    


    public void updateDoorGroup(Map<String, Object> paramMap) {

        update(sqlNameSpace+"updateDoorGroup", paramMap);
    }

    public void deleteDoorGroup(int id) {

        delete(sqlNameSpace+"deleteDoorGroup", id);
    }

    public int getDoorGroupNameVerification(HashMap<String, Object> paramMap) {
        return selectOne(sqlNameSpace+"selectDoorGroupNameVerification", paramMap);
    }

    public void addDoorInDoorGroup(Map<String, Object> paramMap) {

        insert(sqlNameSpace+"insertDoorInDoorGroup", paramMap);
    }

    public void updateDoorInDoorGroup(Map<String, Object> paramMap) {

        update(sqlNameSpace+"updateDoorInDoorGroup", paramMap);
    }

    public void deleteDoorInDoorGroup(Map<String, Object> paramMap) {
        update(sqlNameSpace+"deleteDoorInDoorGroup", paramMap);
    }

    public void updateDoorGroupBatchInit(HashMap paramMap) {
        update(sqlNameSpace+"updateDoorGroupBatchInit", paramMap);
    }

}

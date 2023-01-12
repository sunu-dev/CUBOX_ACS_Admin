package aero.cubox.door.service.impl;

import aero.cubox.door.service.DoorScheduleService;
import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static aero.cubox.util.StringUtil.isEmpty;

@Service("doorScheduleService")
public class DoorScheduleServiceImpl extends EgovAbstractServiceImpl implements DoorScheduleService {

    @Resource(name="doorScheduleDAO")
    private DoorScheduleDAO doorScheduleDAO;

    @Resource(name="doorGroupDAO")
    private DoorGroupDAO doorGroupDAO;

    /**
     * 출입문 스케줄 목록 조회
     * @param commandMap
     * @return
     */
    @Override
    public List<HashMap> getDoorScheduleList(Map<String, Object> commandMap) {

        return doorScheduleDAO.getDoorScheduleList(commandMap);
    }

    @Override
    public int getDoorScheduleListCount(Map<String, Object> commandMap) {
        return doorScheduleDAO.getDoorScheduleListCount(commandMap);
    }

    /**
     * 출입문 스케줄 상세
     * @param id
     * @return
     */
    @Override
    public HashMap getDoorScheduleDetail(int id) {
        return  doorScheduleDAO.getDoorScheduleDetail(id);
    }

    /**
     * 출입문 스케줄 등록
     *
     * @param commandMap
     * @return
     */
    @Override
    public String addSchedule(Map<String, Object> commandMap) {
        String newScheduleId = "";

        doorScheduleDAO.addSchedule(commandMap);

        newScheduleId = commandMap.get("scheduleId").toString();
/*

        HashMap paramMap = new HashMap();

        //출입권한-출입문 table에 door_id Insert
        if( !isEmpty((String) commandMap.get("doorGroupIds"))){

            String doorGroupIds = "";
            doorGroupIds = commandMap.get("doorGroupIds").toString();

            if( doorGroupIds.length() > 0 ){
                String[] doorGroupIdArr = doorGroupIds.split("/");
                for (int i = 0; i < doorGroupIdArr.length; i++) {
                    paramMap.put("id", doorGroupIdArr[i]);
                    paramMap.put("doorSchId", newScheduleId);

                    doorGroupDAO.updateDoorGroup(paramMap);
                }
            }
        }
*/

        return newScheduleId;
    }

    /**
     * 출입문 스케쥴 수정
     * @param commandMap
     */
    @Override
    public void updateSchedule(Map<String, Object> commandMap) {
        doorScheduleDAO.updateSchedule(commandMap);
/*
        HashMap paramMap = new HashMap();

        String doorGroupIds = commandMap.get("doorGroupIds").toString();
        String doorSchId = commandMap.get("id").toString();

        paramMap.put("doorSchId", doorSchId);
        List<HashMap> doorGroupList = doorGroupDAO.getDoorGroupList(paramMap);

        if( doorGroupList.size() > 0 ){
            for (int i = 0; i < doorGroupList.size(); i++) {
                paramMap.put("id", doorGroupList.get(i).get("id"));

                doorGroupDAO.updateDoorGroupBatchInit(paramMap);
            }
        }

        if( doorGroupIds.length() > 0 ){
            String[] doorGroupIdArr = doorGroupIds.split("/");
            for (int i = 0; i < doorGroupIdArr.length; i++) {
                paramMap.put("id", doorGroupIdArr[i]);

                doorGroupDAO.updateDoorGroup(paramMap);
            }
        }
        
        */
    }


    /**
     * 출입문 스케쥴 삭제
     * @param commandMap
     */
    @Override
    public void deleteSchedule(Map<String, Object> commandMap) {
        HashMap paramMap = new HashMap();

        paramMap.put("doorSchId",  commandMap.get("id"));

        doorScheduleDAO.deleteScheduleByDay(paramMap);
        doorScheduleDAO.deleteSchedule(commandMap);

    }

    /**
     * 요일별 스게쥴 상세
     * @param commandMap
     * @return
     */
    @Override
    public List<HashMap> getScheduleByDayDetailList(Map<String, Object> commandMap) {
        return  doorScheduleDAO.getScheduleByDayDetailList(commandMap);
    }

    /**
     * 요일별 스케쥴 등록
     * @param commandMap
     */
    @Override
    public void addScheduleByDay(Map<String, Object> commandMap) {

        doorScheduleDAO.addScheduleByDay(commandMap);
    }

    /**
     * 요일별 스케쥴 수정
     * @param commandMap
     */
    @Override
    public void updateScheduleByDay(Map<String, Object> commandMap) {

        doorScheduleDAO.addScheduleByDay(commandMap);
    }

    /**
     * 요일별 스케쥴 삭제
     * @param commandMap
     */
    @Override
    public void deleteScheduleByDay(Map<String, Object> commandMap) {
        doorScheduleDAO.deleteScheduleByDay(commandMap);
    }

    @Override
    public int getDoorScheduleNameVerification(HashMap<String, Object> param) {
        return doorScheduleDAO.getDoorScheduleNameVerification(param);
    }

    @Override
    public int getDayScheduleExistsCount(Map<String, Object> commandMap) {
        return doorScheduleDAO.getDayScheduleExistsCount(commandMap);
    }
}

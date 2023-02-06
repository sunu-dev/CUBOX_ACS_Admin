package aero.cubox.door.service.impl;

import aero.cubox.door.service.DoorService;
import aero.cubox.util.StringUtil;
import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static aero.cubox.door.controller.DoorController.getValue;

@Service("doorService")
public class DoorServiceImpl extends EgovAbstractServiceImpl implements DoorService {

    @Resource(name="doorDAO")
    private DoorDAO doorDAO;

    @Resource(name="doorGroupDAO")
    private DoorGroupDAO doorGroupDAO;

    /**
     * 출입문 목록 조회
     * @param paramMap
     * @return
     */
    @Override
    public List<Map> getDoorList(Map<String, Object> paramMap) {

        return doorDAO.getDoorList(paramMap);
    }

    /**
     * 출입문 정보 조회
     * @param paramMap
     * @return
     */
    @Override
    public Map getDoorDetail(Map<String, Object> paramMap) {

        return doorDAO.getDoorDetail(paramMap);
    }

    /**
     * 출입문 등록
     *
     * @param commandMap
     * @return
     */
    @Override
    @Transactional
    public String addDoor(Map<String, Object> commandMap) {

        String doorCd = commandMap.get("doorCd").toString();

        if (doorCd.length() < 6) {
            String preNum = "";
            int num = 6 - doorCd.length();
            for (int j = 0; j < num; j++) {
                preNum += "0";
            }
            commandMap.put("doorCd", preNum + doorCd);
        }

        doorDAO.insertDoor(commandMap);

        String newDoorId = "";
        newDoorId = commandMap.get("doorId").toString();

        HashMap paramMap = new HashMap();

        if (!StringUtil.isEmpty(commandMap.get("doorId").toString())) {

            //도어그룹의 스케줄에 출입문 id Update
            if (!StringUtil.isEmpty((String) commandMap.get("doorGroupId"))) {

                paramMap.put("doorId", newDoorId);
                paramMap.put("doorgrpId", commandMap.get("doorGroupId"));

                doorGroupDAO.addDoorInDoorGroup(paramMap);
            }

            //단말기정보에 출입문 id Update
            if (!StringUtil.isEmpty((String) commandMap.get("terminalIds"))) {

                paramMap.put("doorId", newDoorId);
                paramMap.put("doorCd", commandMap.get("doorCd"));
                paramMap.put("id", commandMap.get("terminalIds"));

                doorDAO.updateDoorIdForTerminal(paramMap);
            }

            //출입권한-출입문 table에 door_id Insert
            if (!StringUtil.isEmpty((String) commandMap.get("authGrIds"))) {

                String authGrIds = "";
                authGrIds = commandMap.get("authGrIds").toString();

                if (authGrIds.length() > 0) {
                    String[] authGrIdArr = authGrIds.split("/");
                    for (int i = 0; i < authGrIdArr.length; i++) {
                        paramMap.put("authId", authGrIdArr[i]);
                        paramMap.put("doorId", newDoorId);

                        doorDAO.insertDoorIdForAuthDoor(paramMap);
                    }
                }
            }
        }
        return newDoorId;
    }

    /**
     * 출입문 수정
     * @param commandMap
     */
    @Override
    public void updateDoor(Map<String, Object> commandMap) {
        doorDAO.updateDoor(commandMap);

        HashMap paramMap = new HashMap();

        //출입문그룹의 스케줄에 출입문 id - Insert or Update
        if (!StringUtil.isEmpty((String) commandMap.get("doorGroupId"))) {

            paramMap.put("doorId", commandMap.get("id"));
            paramMap.put("doorgrpId", commandMap.get("doorGroupId"));

            doorGroupDAO.deleteDoorInDoorGroup(paramMap);
            doorGroupDAO.addDoorInDoorGroup(paramMap);
        }

        //단말기정보에 출입문 id Update
        if (!StringUtil.isEmpty((String) commandMap.get("terminalIds"))) {

            paramMap.put("doorId", commandMap.get("id"));
            paramMap.put("doorCd", commandMap.get("doorCd"));
            paramMap.put("id", commandMap.get("terminalIds"));

            doorDAO.updateDoorIdForTerminalInit(paramMap);
            doorDAO.updateDoorIdForTerminal(paramMap);
        }

        //출입권한-출입문 table에 door_id Delete-Insert
        if (!StringUtil.isEmpty((String) commandMap.get("authGrIds"))) {

            paramMap.put("doorId", commandMap.get("id"));

            String authGrIds = "";
            authGrIds = commandMap.get("authGrIds").toString();

            if( authGrIds.length() > 0 ) {
                String[] authGrIdArr = authGrIds.split("/");
                for (int i = 0; i < authGrIdArr.length; i++) {
                    paramMap.put("authId", authGrIdArr[i]);

                    doorDAO.deleteDoorIdForAuthDoor(paramMap);
                    doorDAO.insertDoorIdForAuthDoor(paramMap);
                }
            }
        }
    }

    /**
     * 출입문 삭제
     * @param commandMap
     */
    @Override
    public void deleteDoor(Map<String, Object> commandMap) {

        String doorId = commandMap.get("id").toString();

        HashMap paramMap = new HashMap();

        //단말기정보에 출입문 id - Update
        if (!StringUtil.isEmpty((String) commandMap.get("terminalIds"))) {

            paramMap.put("doorId", doorId);

            doorDAO.updateDoorIdForTerminalInit(paramMap);
//            doorDAO.updateDoorIdForTerminal(paramMap);
        }

        //출입권한-출입문 table에 door_id Delete-Insert
        if (!StringUtil.isEmpty((String) commandMap.get("authGrIds"))) {

            paramMap.put("doorId", doorId);
            String authGrIds = "";
            authGrIds = commandMap.get("authGrIds").toString();

            if (authGrIds.length() > 0) {
                String[] authGrIdArr = authGrIds.split("/");
                for (int i = 0; i < authGrIdArr.length; i++) {
                    paramMap.put("authId", authGrIdArr[i]);
                    doorDAO.deleteDoorIdForAuthDoor(paramMap);
                }
            }
        }

        doorDAO.deleteDoor(commandMap);
    }


    @Override
    public void deleteDoorAll() {
        doorDAO.deleteDoorAll();
    }

    //Workplace
    /**
     * 사업장 목록 조회
     * @param paramMap
     * @return
     */
    @Override
    public List<HashMap> getWorkplaceList(Map<String, Object> paramMap) {

        return doorDAO.getWorkplaceList(paramMap);
    }


    //Building
    /**
     * 빌딩 목록 조회
     * @param paramMap
     * @return
     */
    @Override
    public List<HashMap> getBuildingList(Map<String, Object> paramMap) {

        return doorDAO.getBuildingList(paramMap);
    }
    @Override
    public Map getBuildingDetail(Map<String, Object> paramMap) {
        return doorDAO.getBuildingDetail(paramMap);
    }

    @Override
    @Transactional
    public String addBuilding(HashMap paramMap) {

        String buildingCd = paramMap.get("buildingCd").toString();

        // buildingCd 2자리수 변형
        if (buildingCd.length() < 2) {
            String preNum = "";
            int num = 2 - buildingCd.length();
            for (int j = 0; j < num; j++) {
                preNum += "0";
            }
            paramMap.put("buildingCd", preNum + buildingCd);
        }

        doorDAO.insertBuilding(paramMap);

        String newBuildingId = "";
        newBuildingId = paramMap.get("buildingId").toString();

        paramMap.put("buildingId", newBuildingId);

        //출입권한-빌딩 table에 buildingId Insert
        if (!StringUtil.isEmpty((String) paramMap.get("authGrIds"))) {

            String authGrIds = "";
            authGrIds = paramMap.get("authGrIds").toString();

            if (authGrIds.length() > 0) {
                String[] authGrIdArr = authGrIds.split("/");
                for (int i = 0; i < authGrIdArr.length; i++) {
                    paramMap.put("authId", authGrIdArr[i]);
                    paramMap.put("buildingId", newBuildingId);

                    doorDAO.insertDoorIdForAuthDoor(paramMap);
                }
            }
        }
        return newBuildingId;
    }

    /**
     * 빌딩코드 조회
     * @param buildingId
     * @return
     */
    public String getBuildingCd(String buildingId) {
        return doorDAO.getBuildingCd(buildingId);
    }


    /**
     * 출입문 수정
     * @param paramMap
     */
    @Override
    public void updateBuilding(Map<String, Object> paramMap) {
        doorDAO.updateBuilding(paramMap);
        //출입권한-출입문 table에 door_id Delete-Insert
        if( !StringUtil.isEmpty((String) paramMap.get("authGrIds"))){

            String authGrIds = "";
            authGrIds = paramMap.get("authGrIds").toString();

            if( authGrIds.length() > 0 ){
                String[] authGrIdArr = authGrIds.split("/");
                for (int i = 0; i < authGrIdArr.length; i++) {
                    paramMap.put("authId", authGrIdArr[i]);

                    doorDAO.deleteBuildingIdForAuthBuilding(paramMap);
                    doorDAO.insertBuildingIdForAuthBuilding(paramMap);
                }
            }
        }
    }

    @Override
    public void deleteBuilding(Map<String, Object> commandMap) {
        doorDAO.deleteBuilding(commandMap);
    }

    @Override
    public void deleteBuildingAll() {
        doorDAO.deleteBuildingAll();
    }


    //Area

    /**
     * 구역 목록 조회
     * @param paramMap
     * @return
     */
    @Override
    public List<HashMap> getAreaList(Map<String, Object> paramMap) {

        return doorDAO.getAreaList(paramMap);
    }
    @Override
    public Map getAreaDetail(HashMap<String, Object> paramMap) {
        return doorDAO.getAreaDetail(paramMap);
    }


    @Override
    public String addArea(HashMap paramMap) {

        doorDAO.insertArea(paramMap);

        String newAreaId = "";
        newAreaId = paramMap.get("areaId").toString();
        return newAreaId;
    }

    @Override
    public void updateArea(Map<String, Object> paramMap) {

        doorDAO.updateArea(paramMap);
    }

    @Override
    public void deleteArea(Map<String, Object> commandMap) {
        doorDAO.deleteArea(commandMap);
    }

    @Override
    public void deleteAreaAll() {
        doorDAO.deleteAreaAll();
    }


    //Floor
    /**
     * 층 목록
     * @param paramMap
     * @return
     */
    @Override
    public List<HashMap> getFloorList(Map<String, Object> paramMap) {

        return doorDAO.getFloorList(paramMap);
    }

    @Override
    public Map getFloorDetail(Map<String, Object> paramMap) {
        return doorDAO.getFloorDetail(paramMap);
    }

    @Override
    @Transactional
    public String addFloor(HashMap paramMap) {
        String floorCd = paramMap.get("floorCd").toString();

        // floorCd 2자리수 변형
        if (floorCd.length() < 2) {
            String preNum = "";
            int num = 2 - floorCd.length();
            for (int j = 0; j < num; j++) {
                preNum += "0";
            }
            paramMap.put("floorCd", preNum + floorCd);
        }
        doorDAO.insertFloor(paramMap);

        String newFloorId = "";
        newFloorId = paramMap.get("floorId").toString();

        return newFloorId;
    }

    @Override
    public void updateFloor(Map<String, Object> paramMap) {
        doorDAO.updateFloor(paramMap);
    }

    @Override
    public void deleteFloor(Map<String, Object> commandMap) {
        doorDAO.deleteFloor(commandMap);
    }

    @Override
    public void deleteFloorAll() {
        doorDAO.deleteFloorAll();
    }

    /**
     * 층코드 조회
     * @param floorId
     * @return
     */
    public String getFloorCd(String floorId) {
        return doorDAO.getFloorCd(floorId);
    }

    @Override
    public int getTerminalUseCnt(HashMap<String, Object> param) {
        return doorDAO.getTerminalUseCnt(param);
    }

    @Override
    public int getBuildingNameVerification(HashMap<String, Object> param) {
        return doorDAO.getBuildingNameVerification(param);
    }
    @Override
    public int getAreaNameVerification(HashMap<String, Object> param) {
        return doorDAO.getAreaNameVerification(param);
    }
    @Override
    public int getFloorNameVerification(HashMap<String, Object> param) {
        return doorDAO.getFloorNameVerification(param);
    }
    @Override
    public int getDoorNameVerification(HashMap<String, Object> param) {
        return doorDAO.getDoorNameVerification(param);
    }

    /**
     * 단말기 목록 조회
     *
     * @param commandMap
     * @return
     */
    @Override
    public List<HashMap> getTerminalList(Map<String, Object> commandMap) {
        return doorDAO.getTerminalList(commandMap);
    }

    @Override
    @Transactional
    public int addBuildingFloorDoor(Sheet sheet) {

        // Building Area Floor Door 삭제
        doorDAO.deleteDoorAll();
        doorDAO.deleteFloorAll();
        doorDAO.deleteAreaAll();
        doorDAO.deleteBuildingAll();

        int cnt = 0;
        HashMap paramMap;
        HashMap buildingMap = new HashMap();
        HashMap floorMap = new HashMap();
        HashMap doorMap = new HashMap();

        // 1. Building
        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);

            // 행이 없으면 패스
            if (row == null) continue;

            String buildingNm = getValue(row.getCell(1)).replaceAll("\n", "<br>");                                               // 빌딩 명
            String buildingCd = getValue(row.getCell(5)).replaceAll("\n", "<br>");                                               // 빌딩 코드

            if (!buildingMap.containsValue(String.format("%02d", Integer.parseInt(buildingCd)))) { // buildingCd가 buildingMap에 없는 경우
                buildingMap.put(buildingNm, String.format("%02d", Integer.parseInt(buildingCd)));

                HashMap param = new HashMap();
                param.put("buildingNm", buildingNm);
                param.put("buildingCd", String.format("%02d", Integer.parseInt(buildingCd)));
                param.put("workplaceId", 1);

                addBuilding(param);
            }
        }

        // Building List
        paramMap = new HashMap();
        List<Map> buildingList = getBuildingList(paramMap);   //빌딩 목록

        // 2. Floor
        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);

            if (row == null) continue;

            HashMap<String, String> floorInfo = replaceFloorInfo
                                (getValue(row.getCell(2)).replaceAll("\n", "<br>")
                                , getValue(row.getCell(6)).replaceAll("\n", "<br>"));

            String buildingNm = getValue(row.getCell(1)).replaceAll("\n", "<br>");                                            // 빌딩 명
            String buildingCd = String.format("%02d", Integer.parseInt(getValue(row.getCell(5)).replaceAll("\n", "<br>")));   // 빌딩 코드
            String buildingId = getBuildingId(buildingList, buildingNm, buildingCd);                                                                 // 빌딩 id
            String floorNm = floorInfo.get("floorNm");                                                                                               // 층 명
            String floorCd = floorInfo.get("floorCd");                                                                                               // 층 코드

            if (!floorMap.containsValue(buildingCd + "_" + floorCd)) {
                floorMap.put(buildingNm + "_" + floorNm, buildingCd + "_" + floorCd);

                if (!buildingId.equals("")) {
                    HashMap param = new HashMap();
                    param.put("floorNm", floorNm);
                    param.put("floorCd", floorCd);
                    param.put("buildingId", buildingId);
                    param.put("buildingCd", buildingCd);

                    addFloor(param);
                }
            }
        }

        // Floor List
        paramMap = new HashMap();
        List<HashMap> floorList = getFloorList(paramMap);

        // 3. Door
        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);

            if (row == null) continue;

            String buildingNm = getValue(row.getCell(1)).replaceAll("\n", "<br>");                                              // 빌딩 명
            String doorNm = getValue(row.getCell(3)).replaceAll("\n", "<br>");                                                  // 출입문 명
            String terminalCd = getValue(row.getCell(4)).replaceAll("\n", "<br>");                                             // 단말기 코드
            String buildingCd = String.format("%02d", Integer.parseInt(getValue(row.getCell(5)).replaceAll("\n", "<br>")));     // 빌딩 코드 (2자리로 넣어야함)
            String floorCd = getValue(row.getCell(6)).replaceAll("\n", "<br>");                                                 // 층 코드 (2자리로 넣어야함)
            String doorCd = getValue(row.getCell(7)).replaceAll("\n", "<br>");                                                  // 출입문 코드
            String authGrIds = getValue(row.getCell(8)).replaceAll("\n", "<br>");                                               // 빌딩 명
            String buildingId = getBuildingId(buildingList, buildingNm, buildingCd);                                                                   // 빌딩 id
            String floorId = getFloorId(floorList, floorCd, buildingCd);                                                                               // 층 id

            // doorCd 6자리수 변형
            if (doorCd.length() < 6) {
                String preNum = "";
                int num = 6 - doorCd.length();
                for (int j = 0; j < num; j++) {
                    preNum += "0";
                }
                doorCd = preNum + doorCd;
            }

            // TODO: terminalCd로 terminalId 가져오기
            String terminalId = doorDAO.getTerminalId(terminalCd);

            // TODO: authGroupIds 가공


            if (!doorMap.containsValue(doorCd)) {
                doorMap.put(doorNm, doorCd);

                HashMap param = new HashMap();
                param.put("buildingCd", buildingCd);
                param.put("floorCd", floorCd);
                param.put("doorCd", doorCd);
                param.put("buildingId", buildingId);
                param.put("areaId", null);
                param.put("floorId", floorId);
                param.put("doorNm", doorNm);
                param.put("terminalIds", terminalId);
//                param.put("authGrIds", authGrIds);

                String newDoorId = addDoor(param);
                if (newDoorId != "") cnt++;

            } else {
                return -1;
            }
        }
        return cnt;
    }

    public HashMap replaceFloorInfo(String floorNm, String floorCd) {
        HashMap floorInfo = new HashMap();
        floorInfo.put("floorNm", floorNm);
        floorInfo.put("floorCd", floorCd);

        // floorNm PH층으로 통일
        if (floorNm.matches(".*PH*.") || floorNm.matches(".*ph*.") || floorNm.matches(".*옥상*.")) {
            floorInfo.put("floorNm", "PH층");
        }
        // floorCd 2자리수 변형
        if (floorCd.length() < 2) {
            floorInfo.put("floorCd", "0" + floorCd);
        }
        return floorInfo;
    }

    public String getBuildingId(List<Map> buildingList, String buildingNm, String buildingCd) {
        String buildingId = "";

        for (int j = 0; j < buildingList.size(); j++) {
            if (buildingList.get(j).get("building_nm").equals(buildingNm) && buildingList.get(j).get("building_cd").equals(buildingCd)) {
                buildingId = buildingList.get(j).get("id").toString();
                break;
            }
        }
        return buildingId;
    }

    public String getFloorId(List<HashMap> floorList, String floorCd, String buildingCd) {
        String floorId = "";

        for (int j = 0; j < floorList.size(); j++) {
            if (floorList.get(j).get("floor_cd").equals(floorCd) && floorList.get(j).get("building_cd").equals(buildingCd)) {
                floorId = floorList.get(j).get("id").toString();
                break;
            }
        }
        return floorId;
    }

}

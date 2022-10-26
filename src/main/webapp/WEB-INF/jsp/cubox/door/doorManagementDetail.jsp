<%--
  Created by IntelliJ IDEA.
  User: USER
  Date: 2022-08-31
  Time: 오후 1:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<jsp:include page="/WEB-INF/jsp/cubox/common/checkPasswd.jsp" flush="false"/>

<style>
    .tb_write_p1 tbody th {
        text-align: center;
    }
    .tb_write_02 tbody tr {
        /*height: 70px;*/
        /*height: 51px;*/
        height: 57.5px;
    }
    .detailList tr td {
        text-align: center;
    }
    .detailList tr td select {
        float: none;
    }
    .detailList tr td input,
    .detailList tr td select,
    .detailList tr td textarea {
        width: 100%;
    }

    .title_s {
        font-size: 20px;
    }
    #gateInfo {
        width: 100%;
        height: 690px;
        border: 1px solid black;
    }
    #treeDiv {
        width: 100%;
        height: 631px;
        border-bottom: 1px solid #ccc;
        padding: 10px 45px;
        padding: 10px 45px;
        overflow: auto;
    }
    #btnTerminalPick, #btnDoorAuthPick {
        /*width: 100px;*/
        /*width: 20%;*/
        width: 100%;
        border: none;
    }
    .tb_list tr td {
        text-align: center;
    }
    thead {
        position: sticky;
        top: 0;
    }
    #tdAuthConf tr, #tdAuthTotal tr {
        height: 40px;
        text-align: center;
    }
    .disabled {
        pointer-events: none;
        background-color: lightgray;
    }
    .divAddNode {
        display: inline-block;
    }
    .divAddNode label,
    .divAddNode label input {
        /* 드래그 방지 */
        font-size: small;
        -ms-user-select: none;
        -moz-user-select: none;
        -khtml-user-select: none;
        -webkit-user-select: none;
        user-select: none;
    }
    .title_box {
        margin-top: 10px;
    }
</style>

<script type="text/javascript">

    $(function () {
        $(".title_tx").html("출입문 관리");

        fnGetDoorListAjax();    //출입문 목록

        modalPopup("termPickPopup", "단말기 선택", 910, 520);
        modalPopup("authPickPopup", "권한그룹 선택", 910, 550);

        fnAdd(); // 최초 등록 상태

        let pathArr = [];

        // 빌딩 선택 시,
        $(".selectBuilding").change(function() {
            let val = $(this).val();
            let authType = $("#authType").val();
            let area;
            let options;
            pathArr.splice(1, 1);

            console.log(authType);

            if (authType === "area") {

                pathArr[0] = $(".areaDetailList #dBuilding option:checked").text();
                $("#areaPath").text(pathArr.join(" > "));
                return;

            } else if (authType === "floor") {
                area = $(".floorDetailList #dArea");
                options = $(".floorDetailList #dArea option");
                $(".floorDetailList .dArea").css("display", "block");
                $(".floorDetailList #dArea option[name=selected]").prop("selected", true);
                pathArr[0] = $(".floorDetailList #dBuilding option:checked").text();
                $("#floorPath").text(pathArr.join(" > "));

            } else if (authType === "door") {
                area = $(".doorDetailList #dArea");
                options = $(".doorDetailList #dArea option");
                $(".doorDetailList .dArea").css("display", "block");
                $(".doorDetailList #dArea option[name=selected]").prop("selected", true);
                $(".doorDetailList #dFloor option[name=selected]").prop("selected", true);
                pathArr[0] = $(".doorDetailList #dBuilding option:checked").text();
                $("#doorPath").text(pathArr.join(" > "));
            }

            options.each(function(i, option) { // 빌딩 id와 구역과 area의 bId 속성이 같지 않으면 option에서 제거
                if (val != $(option).attr("bId")) {
                    $(option).css("display", "none");
                }
            });

            // 구역 disabled 해제
            area.prop("disabled", false);
        });

        // 구역 선택 시,
        $(".selectArea").change(function() {
            let val = $(this).val();
            let authType = $("#authType").val();
            let floor;
            let options;
            pathArr.splice(2, 1);

            if (authType === "floor") {
                pathArr[1] = $(".floorDetailList #dArea option:checked").text();
                console.log(pathArr);
                $("#floorPath").text(pathArr.join(" > "));
                return;

            } else if (authType === "door") {
                floor = $(".doorDetailList #dFloor");
                options = $(".doorDetailList #dFloor option");
                $(".doorDetailList .dFloor").css("display", "block");
                $(".doorDetailList #dFloor option[name=selected]").prop("selected", true);

                pathArr[1] = $(".doorDetailList #dArea option:checked").text();
                console.log(pathArr);
                $("#doorPath").text(pathArr.join(" > "));
            }

            options.each(function (i, option) {
                if (val != $(option).attr("aId")) {
                    $(option).css("display", "none");
                }
            });

            // 층 disabled 해제
            floor.prop("disabled", false);
        });

        // 층 선택 시,
        $("#dFloor").change(function() {
            $("#pathFloor").text($("dFloor option:checked").text());
            pathArr[2] = $("#dFloor option:checked").text();
            $("#doorPath").text(pathArr.join(" > "));
        });

        // 단말기 선택 확인
        $('#doorPickConfirm').click(function () {
            console.log("단말기 선택 확인!");
            let selTerminal = $("input[name=checkOne]:checked").val();
            let chkTerminal = $("input[name=checkOne]:checked").closest("tr").children();

            // TODO : 등록된 단말기 여부 확인
            $.ajax({
                type: "GET",
                url: "<c:url value='/door/terminal/confirmUse.do' />",
                data: { terminalId: selTerminal },
                dataType: "json",
                success: function (result) {
                    let cnt = result.terminalUseCnt;
                    console.log(cnt);

                    if (cnt == 1) {
                        alert("이미 사용중인 단말기입니다.");
                        $("input[name=checkOne]").prop("checked", false);
                        if ($("#terminalId").val() !== "") {  // 수정 시 원래대로 체크
                            console.log($("#terminalId").val());
                            $('input[name=checkOne]:input[value=' + $("#terminalId").val() + ']').prop("checked", true);
                        }
                    } else {
                        console.log("사용가능한 단말기입니다.");
                        $("#terminalId").val(selTerminal);              // set terminalId
                        $("#terminalCd").val(chkTerminal.eq(1).html()); // 단말기 코드
                        $("#mgmtNum").val(chkTerminal.eq(2).html());    // 단말기 관리번호
                        closePopup('termPickPopup');
                    }
                }
            });
        });

        // 권한그룹 추가
        $("#add_auth").click(function () {
            $("input[name=chkAuth]:checked").each(function (i) {
                var tag = "<tr>" + $(this).closest("tr").html() + "</tr>";
                tag = tag.replace("chkAuth", "chkAuthConf");
                $("#tdAuthConf").append(tag);
            });

            var ckd = $("input[name=chkAuth]:checked").length;
            for (var i = ckd - 1; i > -1; i--) {
                $("input[name=chkAuth]:checked").eq(i).closest("tr").remove();
            }

            totalCheck();
        });

        // 권한그룹 삭제
        $("#delete_auth").click(function () {
            $("input[name=chkAuthConf]:checked").each(function (i) {
                var tag = "<tr>" + $(this).closest("tr").html() + "</tr>";
                tag = tag.replace("chkAuthConf", "chkAuth");
                $("#tdAuthTotal").append(tag);
            });

            var ckd = $("input[name=chkAuthConf]:checked").length;
            for (var i = ckd - 1; i > -1; i--) {
                $("input[name=chkAuthConf]:checked").eq(i).closest("tr").remove();
            }

            userCheck();
        });

        $("#totalAuthCheckAll").click(function () {
            if ($("#totalAuthCheckAll").prop("checked")) {
                $("input[name=chkAuth]").prop("checked", true);
            } else {
                $("input[name=chkAuth]").prop("checked", false);
            }
        });

        $("#userAuthCheckAll").click(function () {
            if ($("#userAuthCheckAll").prop("checked")) {
                $("input[name=chkAuthConf]").prop("checked", true);
            } else {
                $("input[name=chkAuthConf]").prop("checked", false);
            }
        });

        // 단말기 검색 버튼 클릭시
        $("#btnSearchTerminal").click(function () {
            // param1 : 검색어, param2 : 출입문 미등록 체크박스 value값 Y or N
            let chk = "Y";
            fnGetTerminalListAjax($("#srchMachine").val(), chk);
        });

        // 단말기 검색 버튼 클릭시
        $("#btnSearchAuthGroup").click(function () {
            // param1 : 검색어, param2 : 출입문 미등록 체크박스 value값 Y or N
            fnGetAuthGroupListAjax($("#srchAuth").val());
        });

    });

    // 속성 값 초기화
    function initDetail() {
        let authType = $("#authType").val();

        if (authType === "building") {
            console.log("initDetail building");
            $("#buildingPath").text("");
            $("#buildingNm").val("");
            $("#buildingId").val("");

        } else if (authType === "area") {
            console.log("initDetail area");

            $("#areaPath").text("");
            $("#areaNm").val("");
            $("#areaId").val("");
            // $("#authGroupId").val("");
            $(".areaDetailList #dBuilding").val("");

        } else if (authType === "floor") {
            console.log("initDetail floor");

            $("#floorPath").text("");
            $("#floorNm").val("");
            $("#floorId").val("");
            $("#floorGroup").val("");
            // $("#authGroupId").val("");
            $(".floorDetailList #dBuilding").val("");
            $(".floorDetailList #dArea").val("");
            $(".floorDetailList [name=doorEditSelect]").prop("disabled", true);

        } else if (authType === "door") {
            console.log("initDetail door");

            $("#doorPath").text("");
            $("#doorId").val("");
            $("#doorNm").val("");
            $("#terminalCd").val("");
            $("#mgmtNum").val("");
            $("#doorGroup").val("");
            $("#terminalId").val("");
            $("#authGroupId").val("");
            $(".doorDetailList #dBuilding").val("");
            $(".doorDetailList #dArea").val("");
            $(".doorDetailList #dFloor").val("");
            $(".doorDetailList [name=doorEditSelect]").prop("disabled", true);
        }

        $("option[name='selected']").prop("selected", true);
        $("#titleProp").text("속성");

    }

    // 권한 타입 set
    function setType(authType) {
        $("#authType").val(authType);
    }

    // 권한 타입 초기화
    function initType() {
        $("#authType").val("");
    }

    // 출입문 속성 보여주기
    function viewDoorDetail() {
        $(".doorDetailList").css("display", "table-row-group");
        hideBuildingDetail();
        hideAreaDetail();
        hideFloorDetail();
        viewButtons();
    }

    // 출입문 속성 숨기기
    function hideDoorDetail() {
        $(".doorDetailList").css("display", "none");
        hideButtons();
    }

    // 빌딩 속성 보여주기
    function viewBuildingDetail() {
        $(".buildingDetailList").css("display", "table-row-group");
        hideAreaDetail();
        hideFloorDetail();
        hideDoorDetail();
        viewButtons();
    }

    // 빌딩 속성 숨기기
    function hideBuildingDetail() {
        $(".buildingDetailList").css("display", "none");
        hideButtons();
    }

    // 구역 속성 보여주기
    function viewAreaDetail() {
        $(".areaDetailList").css("display", "table-row-group");
        hideBuildingDetail();
        hideFloorDetail();
        hideDoorDetail();
        viewButtons();
    }

    // 구역 속성 숨기기
    function hideAreaDetail() {
        $(".areaDetailList").css("display", "none");
        hideButtons();
    }

    // 층 속성 보여주기
    function viewFloorDetail() {
        $(".floorDetailList").css("display", "table-row-group");
        hideBuildingDetail();
        hideAreaDetail();
        hideDoorDetail();
        viewButtons();
    }

    // 층 속성 숨기기
    function hideFloorDetail() {
        $(".floorDetailList").css("display", "none");
        hideButtons();
    }

    // 버튼 보여주기
    function viewButtons() {
        $("#btn_wrapper").css("display", "block");
    }

    // 버튼 숨기기
    function hideButtons() {
        $("#btn_wrapper").css("display", "none");
    }

    // title 설정
    function setTitle(type, txt) {
        if (type === "add") {
            $("#titleProp").text(txt + " 추가");
        } else if (type === "detail") {
            $("#titleProp").text(txt + " 속성");
        }
    }

    // 빌딩 속성 뿌려주기
    function getBuildingDetail(id) {
        console.log("getBuildingDetail buildingId => " + id);

        setType("building");
        initDetail();
        fnCancelEditMode();
        viewBuildingDetail();
        setTitle("detail", "빌딩");

        $("#buildingId").val(id);
        let buildingId = $("#buildingId").val();
        console.log(buildingId);

        // 빌딩 정보
        $.ajax({
            type: "GET",
            url: "<c:url value='/door/building/detail.do' />",
            data: { buildingId: buildingId },
            dataType: "json",
            success: function (result) {
                console.log(result);
                let dInfo = result.doorInfo;
                $("#buildingPath").text(dInfo.building_nm);     // 경로
                $("#buildingId").val(dInfo.id);                 // 빌딩 id
                $("#buildingNm").val(dInfo.building_nm);        // 빌딩 명
            }
        });

    }

    // 구역 속성 뿌려주기
    function getAreaDetail(id) {
        console.log("getAreaDetail areaId => " + id);

        setType("area");
        initDetail();
        fnCancelEditMode();
        viewAreaDetail();
        setTitle("detail", "구역");

        $("#areaId").val(id);
        let areaId = $("#areaId").val();
        console.log(areaId);

        // 구역 정보
        $.ajax({
            type: "GET",
            url: "<c:url value='/door/area/detail.do' />",
            data: { areaId: areaId },
            dataType: "json",
            success: function (result) {
                console.log(result);
                // TODO: 권한그룹 ID
                let dInfo = result.doorInfo;
                $("#areaPath").text(dInfo.area_nm.replaceAll(" ", " > "));  // 경로
                $("#areaId").val(dInfo.id);                                 // 구역 id
                $("#areaNm").val(dInfo.area_nm);                            // 구역 명
                $(".areaDetailList #dBuilding").val(dInfo.building_id);     // 빌딩
            }
        });
    }

    // 층 속성 뿌려주기
    function getFloorDetail(id) {
        console.log("getFloorDetail floorId => " + id);

        setType("floor");
        initDetail();
        fnCancelEditMode();
        viewFloorDetail();
        setTitle("detail", "층");
        $("#floorId").val(id);

        let floorId = $("#floorId").val();

        // 층 정보
        $.ajax({
            type: "GET",
            url: "<c:url value='/door/floor/detail.do' />",
            data: { floorId: floorId },
            dataType: "json",
            success: function (result) {
                console.log(result);
                // TODO: 권한그룹 ID
                let dInfo = result.doorInfo;
                $("#floorPath").text(dInfo.floor_nm.replaceAll(" ", " > "));   // 경로
                $("#floorId").val(dInfo.id);                                   // 층 id
                $("#floorNm").val(dInfo.floor_nm);                             // 층 명
                $(".floorDetailList #dBuilding").val(dInfo.building_id);       // 빌딩
                $(".floorDetailList #dArea").val(dInfo.area_id);               // 구역
            }
        });

    }

    // 출입문 속성 뿌려주기
    function getDoorDetail(id) {
        console.log("getDoorDetail doorId => " + id);

        setType("door");
        initDetail();
        fnCancelEditMode();
        viewDoorDetail();
        setTitle("detail", "출입문");

        $("#doorId").val(id);
        let doorId = $("#doorId").val();

        //출입문 정보
        $.ajax({
            type: "GET",
            url: "<c:url value='/door/detail.do' />",
            data: { doorId: doorId },
            dataType: "json",
            success: function (result) {
                // TODO : 알람그룹 가져오기, 스케쥴id
                console.log(result);

                let dInfo = result.doorInfo;
                $("#doorPath").text(dInfo.door_nm.replaceAll(" ", " > "));  // 경로
                $("#doorId").val(dInfo.id);                                 // doorId
                $("#doorNm").val(dInfo.door_nm);                            // 출입문 명
                $(".doorDetailList #dBuilding").val(dInfo.building_id);     // 빌딩
                $(".doorDetailList #dArea").val(dInfo.area_id);             // 구역
                $(".doorDetailList #dFloor").val(dInfo.floor_id);           // 층
                // $("#doorSchedule").val(dInfo.sch_id);                       // 스케쥴
                $("#doorAlarmGroup").val(dInfo.alarm_typ);                  // 알람그룹
                $("#terminalId").val(dInfo.terminal_id);                    // 단말기 id
                $("#terminalCd").val(dInfo.terminal_cd);                    // 단말기 코드
                $("#mgmtNum").val(dInfo.mgmt_num);                          // 단말기 관리번호
                $("#authGroupId").val(dInfo.auth_id);                       // 권한그룹 id
                $("#doorGroup").val(dInfo.auth_nm);                         // 권한그룹 명
            }
        });
    }

    // 출입문 관리 - 수정 취소
    function fnCancelEditMode() {
        let authType = $("#authType").val();
        console.log("fnCancelEditMode : " + authType);

        // [확인, 취소] --> [수정, 삭제] 버튼으로 변환
        $("#btnEdit").css("display", "inline-block");
        $("#btnDelete").css("display", "inline-block");
        $("#btnSave").css("display", "none");
        $("#btnCancel").css("display", "none");
        $("[name=doorEdit]").prop("disabled", true);
        $("[name=doorEditSelect]").prop("disabled", true);
        $("[name=doorEditDisabled]").prop("disabled", true);
        $("input[name=createNode]").removeAttr("checked");

        if (authType === "area") {
            // $("#btnAreaAuthPick").addClass("disabled");
        } else if (authType === "floor") {
            // $("#btnFloorAuthPick").addClass("disabled");
        } else if (authType === "door") {
            $("#btnTerminalPick, #btnDoorAuthPick").addClass("disabled");
        }

    }

    // 출입문 관리 - 수정
    function fnEditMode() {

        let authType = $("#authType").val();
        let doorId = $("#doorId").val();
        console.log("fnEditMode : " + authType);

        // [수정, 삭제] --> [확인, 취소] 버튼으로 변환
        $("#btnEdit").css("display", "none");
        $("#btnDelete").css("display", "none");
        $("#btnSave").css("display", "inline-block");
        $("#btnCancel").css("display", "inline-block");
        $("[name=doorEdit]").prop("disabled", false);

       if (authType === "area") {
            // $("#btnAreaAuthPick").removeClass("disabled");
        } else if (authType === "floor") {
            // $("#btnFloorAuthPick").removeClass("disabled");
        } else if (authType === "door") {
            $("#btnTerminalPick, #btnDoorAuthPick").removeClass("disabled");
        }

        if (doorId === "") {
            console.log("doorId 없음");
            $(".doorDetailList #dArea").prop("disabled", true);
        } else {
            console.log("doorId 있음");
            $(".doorDetailList #dArea").prop("disabled", false); // 구역 disable 해제
        }
    }

    // 출입문 관리 - 추가
    function fnAdd() {
        console.log("fnAdd");
        let val = $("input[name=createNode]:checked").val();

        if ($("input[name=createNode]:checked").length > 0) {
            setType(val);
            initDetail();
            fnEditMode();

            if (val === "building") {
                setTitle("add", "빌딩(동)");
                viewBuildingDetail();
                $("#buildingNm").focus();

            } else if (val === "area") {
                setTitle("add", "구역");
                viewAreaDetail();
                $("#areaNm").focus();

            } else if (val === "floor") {
                setTitle("add", "층");
                viewFloorDetail();
                $("#floorNm").focus();

            } else if (val === "door") {
                setTitle("add", "출입문");
                viewDoorDetail();
                $("#doorNm").focus();
            }

            $(".nodeSel").toggleClass("nodeSel node");
        }
    }

    // 출입문 관리 - 취소
    function fnCancel() {
        let authType = $("#authType").val();
        console.log("fnCancel " + authType);

        if (authType === "building") {
            let buildingId = $("#buildingId").val();
            if (buildingId === "") {
                // 추가 시 취소
                initDetail();
                hideBuildingDetail();
                $("input[name=createNode]").removeAttr("checked");
                initType();
            } else {
                // 수정 시 취소
                getBuildingDetail(buildingId);
            }

        } else if (authType === "area") {
            let areaId = $("#areaId").val();
            if (areaId === "") {
                initDetail();
                hideAreaDetail();
                $("input[name=createNode]").removeAttr("checked");
                initType();
            } else {
                getAreaDetail(areaId);
            }

        } else if (authType === "floor") {
            let floorId = $("#floorId").val();
            if (floorId === "") {
                initDetail();
                hideFloorDetail();
                $("input[name=createNode]").removeAttr("checked");
                initType();
            } else {
                getFloorDetail(floorId);
            }

        } else if (authType === "door") {
            let doorId = $("#doorId").val();
            if (doorId === "") {
                initDetail();
                hideDoorDetail();
                $("input[name=createNode]").removeAttr("checked");
                initType();
            } else {
                getDoorDetail(doorId);
            }
        }

    }

    // 빌딩 validation
    function buildingValid() {
        let result = true;
        if (fnIsEmpty($("#buildingNm").val())) {
            alert("빌딩(동) 명칭을 입력하세요.");
            $("#buildingNm").focus();
            return;
        }
        if ($("#buildingId").val() == "" && !fnBuildingNameValidAjax()) {
            return;
        }

        return result;
    }

    // 구역 validation
    function areaValid() {
        let result = true;
        if (fnIsEmpty($("#areaNm").val())) {
            alert("구역 명칭을 입력하세요.");
            $("#areaNm").focus();
            return;
        }
        if (fnIsEmpty($(".areaDetailList #dBuilding").val())) {
            alert("빌딩(동)을 선택해주세요.");
            $(".areaDetailList #dBuilding").focus();
            return;
        }
        if ($("#areaId").val() == "" && !fnAreaNameValidAjax()) {
            return;
        }

        return result;
    }

    // 층 validation
    function floorValid() {
        let result = true;
        if (fnIsEmpty($("#floorNm").val())) {
            alert("층 명칭을 입력하세요.");
            $("#floorNm").focus();
            return;
        }
        if (fnIsEmpty($(".floorDetailList #dBuilding").val())) {
            alert("빌딩(동)을 선택해주세요.");
            $(".floorDetailList #dBuilding").focus();
            return;
        }
        if (fnIsEmpty($(".floorDetailList #dArea").val())) {
            alert("구역을 선택해주세요.");
            $(".floorDetailList #dArea").focus();
            return;
        }
        if ($("#floorId").val() == "" && !fnFloorNameValidAjax()) {
            return;
        }
        return result;
    }

    // 출입문 validation
    function doorValid() {
        let result = true;
        // validation
        if (fnIsEmpty($("#doorNm").val())) {
            alert("출입문 명칭을 입력하세요.");
            $("#doorNm").focus();
            return;
        }
        if (fnIsEmpty($(".doorDetailList #dBuilding").val())) {
            alert("빌딩(동)을 선택해주세요");
            $(".doorDetailList #dBuilding").focus();
            return;
        }
        if (fnIsEmpty($(".doorDetailList #dArea").val())) {
            alert("구역을 선택해주세요");
            $(".doorDetailList #dArea").focus();
            return;
        }
        if (fnIsEmpty($(".doorDetailList #dFloor").val())) {
            alert("층을 선택해주세요");
            $(".doorDetailList #dFloor").focus();
            return;
        }
        // 출입문 명 중복확인
        if ($("#doorId").val() == "" && !fnDoorNameValidAjax()) {
            return;
        }

        return result;
    }

    // 출입문 저장
    function fnSave() {
        // disabled 해제
        $(":disabled").prop("disabled", false);

        let authType = $("#authType").val();
        if (authType === "building") {
            if (buildingValid()) fnSaveBuildingAjax();
        } else if (authType === "area") {
            if (areaValid()) fnSaveAreaAjax();
        } else if (authType === "floor") {
            if (floorValid()) fnSaveFloorAjax();
        } else if (authType === "door") {
            if (doorValid()) fnSaveDoorAjax();
        }
    }

    // 출입문 관리 - 삭제
    function fnDelete() {

        // 출입문에 연결된 단말기/ 권한 그룹 없을 경우
        // if (confirm("연결된 단말기 또는 권한 그룹이 존재 합니다. 삭제 하시겠습니까?")) {
        //     alert("해당 출입문 정보를 삭제하였습니다.");
        // } else {
        //     alert("취소하였습니다.");
        // }
        let authType = $("#authType").val();
        if (authType === "building") {
            fnDeleteBuildingAjax();
        } else if (authType === "area") {
            fnDeleteAreaAjax();
        } else if (authType === "floor") {
            fnDeleteFloorAjax();
        } else if (authType === "door") {
            fnDeleteDoorAjax();
        }
    }

    // 권한그룹 반영
    function authSave() {
        // $("#authGroupId").val($("input[name=chkAuthConf]").val());

        let authGroupIds = [];
        let authGroupHtml = [];
        $("input[name=chkAuthConf]").each(function (i) {
            let ids = $(this).val();
            let html = $(this).closest("tr").children().eq(1).html();
            authGroupIds.push(ids);
            authGroupHtml.push(html);
        });
        console.log(authGroupIds);
        console.log(authGroupHtml);

        $("#authGroupId").val(authGroupIds);
        // let authType = $("#authType").val();

        $("#doorGroup").val(authGroupHtml.join("\r\n"));

        // 권한그룹 textarea에 뿌려주기
        // if (authType === "area") {
        //     $("#areaGroup").val(authGroupHtml.join("\r\n"));
        // } else if (authType === "floor") {
        //     $("#floorGroup").val(authGroupHtml.join("\r\n"));
        // } else if (authType === "door") {
        //     $("#doorGroup").val(authGroupHtml.join("\r\n"));
        // }

    }

    // 권한그룹 선택 저장
    function authConf() {
        console.log("authConf");

        authSave();
        closePopup("authPickPopup");
    }

    function totalCheck() {
        if ($("#totalAuthCheckAll").prop("checked")) {
            $("#totalAuthCheckAll").prop("checked", false);
        }
    }

    function userCheck() {
        if ($("#userAuthCheckAll").prop("checked")) {
            $("#userAuthCheckAll").prop("checked", false);
        }
    }

    // popup open (공통)
    function openPopup(popupNm, id) {

        console.log(id);

        //EAT001 - 건물 ( 빌딩, 구역, 층)
        //EAT002 - 출입문 그룹
        //EAT003 - 출입문
        if (id === "btnTerminalPick") {
            fnGetTerminalListAjax() // 단말기 목록

        } else if (id === "btnDoorAuthPick") {
            fnGetAuthGroupListAjax("", "EAT003"); // 출입문 권한그룹 목록
            // setType("door");
        }
        // else if (id === "btnAreaAuthPick") {
        //     fnGetAuthGroupListAjax("", "EAT001"); // 구역 권한그룹 목록
        //     setType("area");
        //
        // }
        // else if (id === "btnFloorAuthPick") {
        //     fnGetAuthGroupListAjax("", "EAT001"); // 층 권한그룹 목록
        //     setType("floor");
        // }

        // $("#authType").val(id);
        $("#" + popupNm).PopupWindow("open");
    }

    // popup close (공통)
    function closePopup(popupNm) {
        if (popupNm == "termPickPopup") {
            console.log("closepopup - termPickPopup");
            // 단말기 선택 팝업창 초기화
            // $("input[name='checkOne']:checked").attr("checked", false);
        } else if (popupNm == "authPickPopup") {
            // $("input[name='chkAuth']:checked").attr("checked", false);
            // $("input[name='chkAuthConf']:checked").attr("checked", false);
            totalCheck();
            userCheck();
        }
        $("#" + popupNm).PopupWindow("close");
    }


    /////////////////  출입문 목록 ajax - start  /////////////////////

    function fnGetDoorListAjax() {
        console.log("fnGetDoorListAjax1");

        $.ajax({
            type: "GET",
            data: {},
            dataType: "json",
            async: false,
            url: "<c:url value='/door/list.do' />",
            success: function (result) {
                console.log(result);
                // tree 생성
                createTree(true, result, $("#treeDiv"));

                // 빌딩 list update
                $("option[name=buildingData]").remove();
                $.each(result.buildingList, function(i, building) {
                    let tag = "<option name='buildingData' value='" + building.id + "'>" + building.building_nm + "</option>";
                    $(".selectBuilding").append(tag);
                });

                // 구역 list update
                $("option[name=areaData]").remove();
                $.each(result.areaList, function(i, area) {
                    let tag = "<option name='areaData' value='" + area.id + "' class='dArea' bId='" + area.building_id + "'>" + area.area_nm + "</option>";
                    $(".selectArea").append(tag);
                });

                // 층 list update
                $("option[name=floorData]").remove();
                $.each(result.floorList, function(i, floor) {
                   let tag = "<option name='floorData' value='" + floor.id + "' class='dFloor' aId='" + floor.area_id + "'>" + floor.floor_nm + "</option>";
                   $(".selectFloor").append(tag);
                });
            }
        });
    }

    /////////////////  출입문 목록 ajax - end  /////////////////////


    /////////////////  단말기 목록 ajax - start  /////////////////////

    function fnGetTerminalListAjax(param1, param2) {

        console.log("fnGetTerminalListAjax");

        $.ajax({
            type: "GET",
            url: "<c:url value='/door/terminal/list.do' />",
            data: {
                keyword: param1
                , registrationionStatus: param2
            },
            dataType: "json",
            success: function (result) {
                // 값 초기화
                $("#tbTerminal").empty();
                $("#srchMachine").val("");
                console.log(result.terminalList);

                if (result.terminalList.length > 0) {
                    $.each(result.terminalList, function (i, terminal) {
                        let tag = "<tr class='h_35px' style='text-align:center'><td style='padding:0 14px;'>";
                        tag += "<input type='radio' value='" + terminal.id + "' name='checkOne'></td>";
                        tag += "<td>" + terminal.terminalCd + "</td>";
                        tag += "<td>" + terminal.mgmtNum + "</td>";
                        tag += "<td>" + terminal.terminalTyp + "</td>";
                        tag += "<td>" + terminal.doorNm + "</td></tr>";
                        $("#tbTerminal").append(tag);
                    });

                    if ($("#terminalId").val() !== "") {
                        let terminalId = $("#terminalId").val().split("/")[0]; // TODO: '/' 다중으로 오는 데이터는 앞의 데어터만 적용
                        $('input[name=checkOne]:input[value=' + terminalId + ']').prop("checked", true);
                    }
                }
            }
        });
    }

    /////////////////  단말기 목록 조회 ajax - end  /////////////////////


    /////////////////  권한그룹 목록 ajax - start  /////////////////////

    function fnGetAuthGroupListAjax(keyword, type) {

        console.log("fnGetAuthGroupListAjax");
        console.log("type" + type);

        //EAT001 - 건물 ( 빌딩, 구역, 층)
        //EAT002 - 출입문 그룹
        //EAT003 - 출입문

        $.ajax({
            type: "GET",
            url: "<c:url value='/door/authGroup/list.do' />",
            data: {
                keyword: keyword
                , authType: type
            },
            dataType: "json",
            success: function (result) {
                console.log(result);
                $("#tdAuthTotal").empty();
                $("#tdAuthConf").empty();
                $("#srchAuth").val("");

                if (result.authList.length > 0) {
                    $.each(result.authList, function (i, authGroup) {
                        let tag = "<tr><td style='padding: 0 14px;'><input type='checkbox' value='" + authGroup.id + "' name='chkAuth'/></td>";
                        tag += "<td>" + authGroup.authNm + "</td></tr>";
                        $("#tdAuthTotal").append(tag);
                    });

                    console.log("authgroupId");
                    console.log($("#authGroupId").val());
                    if ($("#authGroupId").val() !== "") {
                        let authGroupId = $("#authGroupId").val().split(",");
                        $.each(authGroupId, function(j, authId) {
                            $('input[name=chkAuth]:input[value=' + authId + ']').prop("checked", true);
                            $("#add_auth").click();
                        });

                    }
                }
            }
        });
    }

    /////////////////  권한그룹 목록 ajax - end  /////////////////////


    /////////////////  출입문 저장 ajax - start  /////////////////////

    function fnSaveDoorAjax() {
        let url = "";
        let mode = "";
        let doorId = $("#doorId").val();
        let data = {
            doorNm: $("#doorNm").val(),
            buildingId: $(".doorDetailList #dBuilding").val(),
            areaId: $(".doorDetailList #dArea").val(),
            floorId: $(".doorDetailList #dFloor").val(),
            // scheduleId: $("#doorSchedule").val(),
            doorGroupId: $("#selDoorGroup").val(),
            alarmGroupId: $("#doorAlarmGroup").val(),
            terminalIds: $("#terminalId").val(),
            authGrIds: $("#authGroupId").val()
        };

        if (doorId === "") { // 등록 시
            url = "<c:url value='/door/add.do' />";
            data = data;
            mode = "C";
        } else { // 수정 시
            url = "<c:url value='/door/update.do' />";
            data.doorId = doorId;
            mode = "U";
        }

        console.log(url);
        console.log(data);

        $.ajax({
            type: "POST",
            url: url,
            data: data,
            dataType: "json",
            success: function (returnData) {
                console.log("fnSave: ");
                console.log(returnData);

                if (returnData.resultCode == "Y") {
                    alert("저장되었습니다.");
                    fnGetDoorListAjax();

                    if ("C" === mode ) {
                        if (returnData.newDoorId !== "" ) {
                            console.log("C");
                            getDoorDetail(returnData.newDoorId); //
                        }

                    } else if ("U" === mode) {
                        console.log("U");
                        getDoorDetail(doorId);
                    }

                } else {
                    //등록에 문제가 발생
                    alert("등록에 실패하였습니다.");
                }
            }
        });

        fnCancel();
    }

    /////////////////  출입문 저장 ajax - end  /////////////////////


    /////////////////  빌딩 저장 ajax - start  /////////////////////

    function fnSaveBuildingAjax() {
        let url = "";
        let mode = "";
        let buildingId = $("#buildingId").val();
        let data = {
            buildingNm : $("#buildingNm").val()
            , workplaceId : 1
        };

        if (buildingId === "") { // 등록 시
            console.log("빌딩 등록");
            url = "<c:url value='/door/building/add.do' />";
            data = data;
            mode = "C";
        } else { // 수정 시
            console.log("빌딩 수정");
            url = "<c:url value='/door/building/update.do' />";
            data.buildingId = buildingId;
            mode = "U";
        }

        $.ajax({
            type: "POST",
            url: url,
            data: data,
            dataType: "json",
            success: function (returnData) {
                console.log("fnSave: building");
                console.log(returnData);

                if (returnData.resultCode == "Y") {
                    alert("저장되었습니다.");
                    fnGetDoorListAjax();

                    if ("C" === mode ) {
                        if (returnData.newBuildingId !== "" ) {
                            console.log("C");
                            getBuildingDetail(returnData.newBuildingId); //
                        }

                    } else if ("U" === mode) {
                        console.log("U");
                        getBuildingDetail(buildingId);
                    }

                } else {
                    //등록에 문제가 발생
                    alert("등록에 실패하였습니다.");
                }
            }
        });

        fnCancel();
    }

    /////////////////  빌딩 저장 ajax - end  /////////////////////


    /////////////////  구역 저장 ajax - start  /////////////////////

    function fnSaveAreaAjax() {
        let url = "";
        let mode = "";
        let areaId = $("#areaId").val();
        let data = {
            areaNm : $("#areaNm").val()
            , buildingId : $(".areaDetailList #dBuilding").val()
            // , authGrIds: $("#authGroupId").val()
        };

        if (areaId === "") { // 등록 시
            url = "<c:url value='/door/area/add.do' />";
            data = data;
            mode = "C";
        } else { // 수정 시
            url = "<c:url value='/door/area/update.do' />";
            data.areaId = areaId;
            mode = "U";
        }

        console.log(url);
        console.log(data);

        $.ajax({
            type: "POST",
            url: url,
            data: data,
            dataType: "json",
            success: function (returnData) {
                console.log("fnSave: area");
                console.log(returnData);

                if (returnData.resultCode == "Y") {
                    alert("저장되었습니다.");
                    fnGetDoorListAjax();

                    if ("C" === mode ) {
                        if (returnData.newAreaId !== "" ) {
                            console.log("C");
                            getAreaDetail(returnData.newAreaId);
                        }

                    } else if ("U" === mode) {
                        console.log("U");
                        getAreaDetail(areaId);
                    }

                } else {
                    //등록에 문제가 발생
                    alert("등록에 실패하였습니다.");
                }

            }
        });

        fnCancel();
    }

    /////////////////  구역 저장 ajax - end  /////////////////////


    /////////////////  층 저장 ajax - start  /////////////////////

    function fnSaveFloorAjax() {
        let url = "";
        let mode = "";
        let floorId = $("#floorId").val();
        let data = {
            floorNm : $("#floorNm").val()
            , buildingId : $(".floorDetailList #dBuilding").val()
            , areaId : $(".floorDetailList #dArea").val()
            // , authGrIds: $("#authGroupId").val()
        };

        if (floorId === "") { // 등록 시
            url = "<c:url value='/door/floor/add.do' />";
            data = data;
            mode = "C";
        } else { // 수정 시
            url = "<c:url value='/door/floor/update.do' />";
            data.floorId = floorId;
            mode = "U";
        }
        console.log(url);
        console.log(data);

        $.ajax({
            type: "POST",
            url: url,
            data: data,
            dataType: "json",
            success: function (returnData) {
                console.log("fnSave: floor");
                console.log(returnData);

                if (returnData.resultCode == "Y") {
                    alert("저장되었습니다.");
                    fnGetDoorListAjax();

                    if ("C" === mode ) {
                        if (returnData.newfloorId !== "" ) {
                            console.log("C");
                            getFloorDetail(returnData.newfloorId); //
                        }

                    } else if ("U" === mode) {
                        console.log("U");
                        getFloorDetail(floorId);
                    }

                } else {
                    //등록에 문제가 발생
                    alert("등록에 실패하였습니다.");
                }
            }
        });

        fnCancel();
    }
    /////////////////  층 저장 ajax - end  /////////////////////


    /////////////////  출입문 삭제 ajax - start  /////////////////////

    function fnDeleteDoorAjax() {
        console.log("fnDeleteDoorAjax");
        console.log($("#doorId").val());

        if (confirm("삭제 하시겠습니까?")) {
            $.ajax({
                type: "POST",
                url: "<c:url value='/door/delete.do' />",
                data: { id: $("#doorId").val() },
                dataType: "json",
                success: function (returnData) {
                    console.log("fnDelete door : ");
                    console.log(returnData);

                    if (returnData.resultCode == "Y") {
                        // 삭제 성공
                        alert("해당 출입문 정보를 삭제하였습니다.");
                        fnGetDoorListAjax();
                        initDetail();
                        hideDoorDetail();
                    } else {
                        // TODO: 실패감지가 안됨
                        alert("삭제 실패");
                    }
                }
            });
        }
    }

    /////////////////  출입문 삭제 ajax - end  /////////////////////


    /////////////////  빌딩 삭제 ajax - start  /////////////////////

    function fnDeleteBuildingAjax() {
        console.log("fnDeleteBuildingAjax");
        console.log($("#buildingId").val());

        if (confirm("삭제 하시겠습니까?")) {
            $.ajax({
                type: "POST",
                url: "<c:url value='/door/building/delete.do' />",
                data: { id: $("#buildingId").val() },
                dataType: "json",
                success: function (returnData) {
                    console.log("fnDelete building: ");
                    console.log(returnData);

                    if (returnData.resultCode == "Y") {
                        // 삭제 성공
                        alert("해당 빌딩 정보를 삭제하였습니다.");
                        fnGetDoorListAjax();
                        initDetail();
                        hideBuildingDetail();
                    } else {
                        // TODO: 실패감지가 안됨
                        alert("삭제 실패");
                    }
                }
            });
        }
    }

    /////////////////  빌딩 삭제 ajax - end  /////////////////////


    /////////////////  구역 삭제 ajax - start  /////////////////////

    function fnDeleteAreaAjax() {
        console.log("fnDeleteAreaAjax");
        console.log($("#areaId").val());

        if (confirm("삭제 하시겠습니까?")) {
            $.ajax({
                type: "POST",
                url: "<c:url value='/door/area/delete.do' />",
                data: { id: $("#areaId").val() },
                dataType: "json",
                success: function (returnData) {
                    console.log("fnDelete area : ");
                    console.log(returnData);

                    if (returnData.resultCode == "Y") {
                        // 삭제 성공
                        alert("해당 구역 정보를 삭제하였습니다.");
                        fnGetDoorListAjax();
                        initDetail();
                        hideAreaDetail();
                    } else {
                        // TODO: 실패감지가 안됨
                        alert("삭제 실패");
                    }
                }
            });
        }
    }

    /////////////////  구역 삭제 ajax - end  /////////////////////


    /////////////////  층 삭제 ajax - start  /////////////////////

    function fnDeleteFloorAjax() {
        console.log("fnDeleteFloorAjax");
        console.log($("#floorId").val());

        if (confirm("삭제 하시겠습니까?")) {
            $.ajax({
                type: "POST",
                url: "<c:url value='/door/floor/delete.do' />",
                data: { id: $("#floorId").val() },
                dataType: "json",
                success: function (returnData) {
                    console.log("fnDelete floor: ");
                    console.log(returnData);

                    if (returnData.resultCode == "Y") {
                        // 삭제 성공
                        alert("해당 층 정보를 삭제하였습니다.");
                        fnGetDoorListAjax();
                        initDetail();
                        hideFloorDetail();
                    } else {
                        // TODO: 실패감지가 안됨
                        alert("삭제 실패");
                    }
                }
            });
        }
    }

    /////////////////  층 삭제 ajax - end  /////////////////////


    /////////////////  빌딩 명 중복 확인 ajax - start  /////////////////////

    function fnBuildingNameValidAjax() {
        console.log("fnBuildingNameValidAjax");
        console.log($(".buildingDetailList #buildingNm").val());
        let rtnData;

        $.ajax({
            type: "GET",
            url: "<c:url value='/door/building/name/verification.do' />",
            data: { buildingNm: $(".buildingDetailList #buildingNm").val() },
            async: false,
            dataType: "json",
            success: function (result) {
                console.log("빌딩명중복확인여부: ");
                console.log(result.buildingNameVerificationCnt);

                if (result.buildingNameVerificationCnt != 0) {  // 사용 불가능
                    alert("이미 사용중인 빌딩 명 입니다.");
                    $("#buildingNm").val("");
                    $("#buildingNm").focus();
                    rtnData = false;
                } else {                                    // 사용 가능, 저장!
                    console.log("사용 가능한 빌딩명!");
                    rtnData = true;
                }
            }
        });
        console.log("rtnData =  " + rtnData);
        return rtnData;
    }

    /////////////////  빌딩 명 중복 확인 ajax - start  /////////////////////


    /////////////////  구역 명 중복 확인 ajax - start  /////////////////////

    function fnAreaNameValidAjax() {
        console.log("fnAreaNameValidAjax");
        console.log($(".areaDetailList #areaNm").val());
        let rtnData;

        $.ajax({
            type: "GET",
            url: "<c:url value='/door/area/name/verification.do' />",
            data: { areaNm: $(".areaDetailList #areaNm").val() },
            async: false,
            dataType: "json",
            success: function (result) {
                console.log("구역명중복확인여부: ");
                console.log(result.areaNameVerificationCnt);

                if (result.areaNameVerificationCnt != 0) {  // 사용 불가능
                    alert("이미 사용중인 구역 명 입니다.");
                    $("#areaNm").val("");
                    $("#areaNm").focus();
                    rtnData = false;
                } else {                                    // 사용 가능, 저장!
                    console.log("사용 가능한 구역 명!");
                    rtnData = true;
                }
            }
        });
        console.log("rtnData =  " + rtnData);
        return rtnData;
    }

    /////////////////  구역 명 중복 확인 ajax - start  /////////////////////

    /////////////////  층 명 중복 확인 ajax - start  /////////////////////

    function fnFloorNameValidAjax() {
        console.log("fnFloorNameValidAjax");
        console.log($(".floorDetailList #floorNm").val());
        let rtnData;

        $.ajax({
            type: "GET",
            url: "<c:url value='/door/floor/name/verification.do' />",
            data: { floorNm: $(".floorDetailList #floorNm").val() },
            async: false,
            dataType: "json",
            success: function (result) {
                console.log("층명중복확인여부: ");
                console.log(result.floorNameVerificationCnt);

                if (result.floorNameVerificationCnt != 0) {  // 사용 불가능
                    alert("이미 사용중인 층 명 입니다.");
                    $("#floorNm").val("");
                    $("#floorNm").focus();
                    rtnData = false;
                } else {                                    // 사용 가능, 저장!
                    console.log("사용 가능한 층 명!");
                    rtnData = true;
                }
            }
        });
        console.log("rtnData =  " + rtnData);
        return rtnData;
    }

    /////////////////  층 명 중복 확인 ajax - start  /////////////////////


    /////////////////  출입문 명 중복 확인 ajax - start  /////////////////////

    function fnDoorNameValidAjax() {
        console.log("fnDoorNameValidAjax");
        console.log($(".doorDetailList #doorNm").val());
        let rtnData;

        $.ajax({
            type: "GET",
            url: "<c:url value='/door/name/verification.do' />",
            data: { doorNm: $(".doorDetailList #doorNm").val() },
            async: false,
            dataType: "json",
            success: function (result) {
                console.log("출입문명중복확인여부: ");
                console.log(result.doorNameVerificationCnt);

                if (result.doorNameVerificationCnt != 0) {  // 사용 불가능
                    alert("이미 사용중인 출입문 명 입니다.");
                    $("#doorNm").val("");
                    $("#doorNm").focus();
                    rtnData = false;
                } else {                                    // 사용 가능, 저장!
                    console.log("사용 가능한 출입문!");
                    rtnData = true;
                }
            }
        });
        console.log("rtnData =  " + rtnData);
        return rtnData;
    }

    /////////////////  출입문 명 중복 확인 ajax - start  /////////////////////


</script>

<div class="com_box">
    <div class="totalbox" style="justify-content: end">
        <div class="r_btnbox mb_10">
            <button type="button" class="btn_excel" data-toggle="modal" id="excelDownload" onclick="openExcelDownload();">일괄등록 양식 다운로드</button>
            <button type="button" class="btn_excel" data-toggle="modal">일괄등록</button>
        </div>
    </div>
</div>

<div class="box_w3 mb_20" style="width:1200px; margin-top:0;">

    <%--  출입문  --%>
    <div style="width:550px;">
        <div class="totalbox mb_20">
            <div class="title_s w_50p fl" style="margin-bottom:7px;">
                <img src="/img/title_icon1.png" alt=""/>출입문
            </div>
        </div>
        <%--  출입문 tree  --%>
        <div class="com_box" style="border: 1px solid black; background-color: white;">
            <div id="treeDiv"></div>
            <div class="c_btnbox center mt_10 mb_10" style="height: 35px;">
                <div style="display: inline-block;">
                    <div class="divAddNode mr_10">
                        <label for="addBuilding">
                            <input type="radio" id="addBuilding" name="createNode" class="mr_5" value="building">빌딩(동)
                        </label>
                    </div>

                    <div class="divAddNode mr_10">
                        <label for="addArea">
                            <input type="radio" id="addArea" name="createNode" class="mr_5" value="area">구역
                        </label>
                    </div>

                    <div class="divAddNode mr_10">
                        <label for="addFloor">
                            <input type="radio" id="addFloor" name="createNode" class="mr_5" value="floor">층
                        </label>
                    </div>

                    <div class="divAddNode mr_10">
                        <label for="addDoor">
                            <input type="radio" id="addDoor" name="createNode" class="mr_5" value="door" checked="checked">출입문
                        </label>
                    </div>

                    <button type="button" class="comm_btn ml_10" style="float:none;" onclick="fnAdd();">추가</button>
                </div>
            </div>
        </div>
        <%--  end of 출입문 tree  --%>
    </div>
    <%--  end of 출입문  --%>

    <%--  속성  --%>
    <div style="width:550px;">
        <div class="totalbox mb_20">
            <div class="title_s w_50p fl"><img src="/img/title_icon1.png" alt=""/><span id="titleProp">속성</span></div>
        </div>

        <input type="hidden" id="authType" value="">
        <input type="hidden" id="buildingId" value="">
        <input type="hidden" id="areaId" value="">
        <input type="hidden" id="floorId" value="">
        <input type="hidden" id="doorId" value="">
        <input type="hidden" id="terminalId" value="">
        <input type="hidden" id="authGroupId" value="">

        <%--  테이블  --%>
        <div class="com_box mt_5" style="background-color: white;">
            <div id="gateInfo" class="tb_outbox">
                <table class="tb_write_02 tb_write_p1">
                    <colgroup>
                        <col style="width:30%">
                        <col style="width:57%">
                        <col style="width:13%">
                    </colgroup>

                    <%-- 출입문 추가 --%>
                    <tbody class="doorDetailList detailList" style="display: none;">

                    <tr>
                        <td colspan="3" style="font-size: 17px; text-align: left; padding-left: 20px">
                            <b id="doorPath"></b>
                        </td>
                    </tr>
                    <tr>
                        <th>출입문 명</th>
                        <td colspan="2">
                            <input type="text" id="doorNm" name="doorEdit" maxlength="30" class="input_com" value="" disabled/>
                        </td>
                    </tr>
                    <jsp:include page="/WEB-INF/jsp/cubox/common/buildingSelect.jsp" flush="false" />
<%--                    <tr>--%>
<%--                        <th>빌딩(동)</th>--%>
<%--                        <td colspan="2">--%>
<%--                            <select name="doorEdit" id="dBuilding" class="form-control" style="padding-left:10px;" disabled>--%>
<%--                                <option value="" name="selected">선택</option>--%>
<%--                                <c:forEach items="${buildingList}" var="building" varStatus="status">--%>
<%--                                    <option value='<c:out value="${building.id}"/>'><c:out value="${building.building_nm}"/></option>--%>
<%--                                </c:forEach>--%>
<%--                            </select>--%>
<%--                        </td>--%>
<%--                    </tr>--%>


                    <jsp:include page="/WEB-INF/jsp/cubox/common/areaSelect.jsp" flush="false" />
<%--                        <th>구역</th>--%>
<%--                        <td colspan="2">--%>
<%--                            <select name="doorEditSelect" id="dArea" class="form-control" style="padding-left:10px;" disabled>--%>
<%--                                <option value="" name="selected">선택</option>--%>
<%--                                <c:forEach items="${areaList}" var="area" varStatus="status">--%>
<%--                                    <option value='<c:out value="${area.id}"/>' class="dArea" bId='<c:out value="${area.building_id}"/>'>--%>
<%--                                        <c:out value="${area.area_nm}"/></option>--%>
<%--                                </c:forEach>--%>
<%--                            </select>--%>
<%--                        </td>--%>
<%--                    </tr>--%>
                    <tr>
                        <th>층</th>
                        <td colspan="2">
                            <select name="doorEditSelect" id="dFloor" class="form-control selectFloor" style="padding-left:10px;" disabled>
                                <option value="" name="selected">선택</option>
                                <c:forEach items="${floorList}" var="floor" varStatus="status">
                                    <option name="floorData" value='<c:out value="${floor.id}"/>' class="dFloor"
                                            aId='<c:out value="${floor.area_id}"/>'><c:out value="${floor.floor_nm}"/></option>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
<%--                    <tr>--%>
<%--                        <th>스케쥴</th>--%>
<%--                        <td colspan="2">--%>
<%--                            <select name="doorEdit" id="doorSchedule" class="form-control" style="padding-left:10px;" disabled>--%>
<%--                                <option value="" name="selected">선택</option>--%>
<%--                                <c:forEach items="${scheduleList}" var="schedule" varStatus="status">--%>
<%--                                    <option value='<c:out value="${schedule.id}"/>'><c:out value="${schedule.door_sch_nm}"/></option>--%>
<%--                                </c:forEach>--%>
<%--                            </select>--%>
<%--                        </td>--%>
<%--                    </tr>--%>
                    <tr>
                        <th>스케쥴</th>
                        <td colspan="2">
                            <select name="doorEdit" id="selDoorGroup" class="form-control" style="padding-left:10px;" disabled>
                                <option value="" name="selected">선택</option>
                                <c:forEach items="${doorGroupList}" var="doorGroup" varStatus="status">
                                <option value='<c:out value="${doorGroup.id}"/>'><c:out value="${doorGroup.nm}"/></option>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <th>알람 그룹</th>
                        <td colspan="2">
                            <select name="doorEdit" id="doorAlarmGroup" class="form-control" style="padding-left:10px;" disabled>
                                <option value="" name="selected">선택</option>
                                <c:forEach items="${doorAlarmGrpList}" var="doorAlarmGroup" varStatus="status">
                                    <option value='<c:out value="${doorAlarmGroup.id}"/>'><c:out value="${doorAlarmGroup.nm}"/></option>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <th>단말기 코드</th>
                        <td style="border-right:none; padding-right:0; padding-left:12px;">
                            <input type="text" id="terminalCd" name="doorEditDisabled" maxlength="30" class="input_com" value="" disabled/>
                        </td>
                        <td>
                            <button type="button" id="btnTerminalPick" class="btn_gray3 btn_small disabled" onclick="openPopup('termPickPopup', this.id);">선택</button>
                        </td>
                    </tr>
                    <tr>
                        <th>단말기 관리번호</th>
                        <td colspan="2">
                            <input type="text" id="mgmtNum" name="doorEditDisabled" maxlength="30" class="input_com" value="" disabled/>
                        </td>
                    </tr>
                    <tr>
                        <th>권한 그룹</th>
                        <td style="border-right:none; padding-right:0; padding-left:12px;">
                            <textarea id="doorGroup" name="doorEditDisabled" rows="4" cols="33" class="mt_5 mb_5" style="font-size: 14px; line-height: 1.5; padding: 1px 10px;" disabled></textarea>
                        </td>
                        <td>
                            <button type="button" id="btnDoorAuthPick" class="btn_gray3 btn_small disabled" onclick="openPopup('authPickPopup', this.id);">선택</button>
                        </td>
                    </tr>
                    </tbody>
                    <%-- // 출입문 추가 --%>


                    <%-- 빌딩 추가 --%>
                    <tbody class="buildingDetailList detailList" style="display: none;">
                        <input type="hidden" id="workplaceId" value="1">
                        <tr>
                            <td colspan="3" style="font-size: 17px; text-align: left; padding-left: 20px">
                                <b id="buildingPath"></b>
                            </td>
                        </tr>
                        <tr>
                            <th>빌딩 명</th>
                            <td colspan="2">
                                <input type="text" id="buildingNm" name="doorEdit" maxlength="30" class="input_com" value="" disabled/>
                            </td>
                        </tr>
                    </tbody>
                    <%-- // 빌딩 추가 --%>


                    <%-- 구역 추가 --%>
                    <tbody class="areaDetailList detailList" style="display: none;">
                        <tr>
                            <td colspan="3" style="font-size: 17px; text-align: left; padding-left: 20px">
                                <b id="areaPath"></b>
                            </td>
                        </tr>
                        <tr>
                            <th>구역 명</th>
                            <td colspan="2">
                                <input type="text" id="areaNm" name="doorEdit" maxlength="30" class="input_com" value="" disabled/>
                            </td>
                        </tr>
                        <%-- 빌딩 선택--%>
                        <jsp:include page="/WEB-INF/jsp/cubox/common/buildingSelect.jsp" flush="false" />
<%--                        <tr>--%>
<%--                            <th>권한 그룹</th>--%>
<%--                            <td style="border-right:none; padding-right:0; padding-left:12px;">--%>
<%--                                <textarea id="areaGroup" name="doorEditDisabled" rows="4" cols="33" class="mt_5 mb_5" style="font-size: 14px; line-height: 1.5; padding: 1px 10px;" disabled></textarea>--%>
<%--                            </td>--%>
<%--                            <td>--%>
<%--                                <button type="button" id="btnAreaAuthPick" class="btn_gray3 btn_small disabled" onclick="openPopup('authPickPopup', this.id);">선택</button>--%>
<%--                            </td>--%>
<%--                        </tr>--%>

                    </tbody>
                    <%-- // 구역 추가 --%>


                    <%-- 층 추가 --%>
                    <tbody class="floorDetailList detailList" style="display: none;">
                        <tr>
                            <td colspan="3" style="font-size: 17px; text-align: left; padding-left: 20px">
                                <b id="floorPath"></b>
                            </td>
                        </tr>
                        <tr>
                            <th>층 명</th>
                            <td colspan="2">
                                <input type="text" id="floorNm" name="doorEdit" maxlength="30" class="input_com" value="" disabled/>
                            </td>
                        </tr>
                        <%-- 빌딩 선택 --%>
                        <jsp:include page="/WEB-INF/jsp/cubox/common/buildingSelect.jsp" flush="false" />
                        <%-- 구역 선택 --%>
                        <jsp:include page="/WEB-INF/jsp/cubox/common/areaSelect.jsp" flush="false" />
<%--                        <tr>--%>
<%--                            <th>권한 그룹</th>--%>
<%--                            <td style="border-right:none; padding-right:0; padding-left:12px;">--%>
<%--                                <textarea id="floorGroup" name="doorEditDisabled" rows="4" cols="33" class="mt_5 mb_5" style="font-size: 14px; line-height: 1.5; padding: 1px 10px;" disabled></textarea>--%>
<%--                            </td>--%>
<%--                            <td>--%>
<%--                                <button type="button" id="btnFloorAuthPick" class="btn_gray3 btn_small disabled" onclick="openPopup('authPickPopup', this.id);">선택</button>--%>
<%--                            </td>--%>
<%--                        </tr>--%>
                    </tbody>
                    <%-- // 층 추가 --%>

                </table>

                <div class="c_btnbox center mt_10 mb_10" id="btn_wrapper" style="position: absolute; bottom: 0; display: none;">
                    <div style="display: inline-block;">
                        <button type="button" id="btnEdit" class="comm_btn mr_20" onclick="fnEditMode();">수정</button>
                        <button type="button" id="btnDelete" class="comm_btn" onclick="fnDelete();">삭제</button>
                        <button type="button" id="btnSave" class="comm_btn mr_20" onclick="fnSave();" style="display:none">확인</button>
                        <button type="button" id="btnCancel" class="comm_btn" onclick="fnCancel();" style="display:none">취소</button>
                    </div>
                </div>
            </div>
        </div>
        <%--  end of 테이블  --%>
    </div>
    <%--  end of 속성  --%>
</div>

<%--  단말기 선택 modal  --%>
<div id="termPickPopup" class="example_content" style="display: none;">
    <div class="popup_box">
        <%--  검색 박스 --%>
        <div class="search_box mb_20">
            <div class="search_in">
                <div class="comm_search mr_10">
                    <input type="text" class="input_com" id="srchMachine" name="srchMachine" value="" placeholder="단말기명 / 관리번호 / 단말기 코드" maxlength="30" style="width: 629px;">
                </div>
                <div class="comm_search ml_5 mr_10">
                    <input type="checkbox" id="unregisteredDoor" name="unregisteredDoor" value="unregistered">
                    <label for="unregisteredDoor" class="ml_5" style="position: relative; top: -12px;">출입문 미등록</label><br>
                </div>
                <div class="comm_search ml_40">
                    <div class="search_btn2" id="btnSearchTerminal"></div>
                </div>
            </div>
        </div>
        <%--  end of 검색 박스 --%>
        <div class="tb_outbox mb_20" style="height: 255px; overflow: auto;">
            <table class="tb_list tb_write_02 tb_write_p1">
                <colgroup>
                    <col style="width:5%">
                    <col style="width:28%">
                    <col style="width:20%">
                    <col style="width:22%">
                    <col style="width:25%">
                </colgroup>
                <thead>
                <tr>
                    <th>선택</th>
                    <th>단말기코드</th>
                    <th>관리번호</th>
                    <th>단말기유형</th>
                    <th>출입문명</th>
                </tr>
                </thead>
                <tbody id="tbTerminal">
                </tbody>
            </table>
        </div>

        <div class="c_btnbox">
            <div style="display: inline-block;">
                <button type="button" id="doorPickConfirm" class="comm_btn mr_20">확인</button>
                <button type="button" class="comm_btn" onclick="closePopup('termPickPopup');">취소</button>
            </div>
        </div>
    </div>
</div>
<%--  end of 단말기 선택 modal  --%>

<%--  권한그룹 선택 modal  --%>
<div id="authPickPopup" class="example_content" style="display: none;">

    <div class="popup_box box_w3">
        <%--  검색 박스 --%>
        <div class="search_box mb_20">
            <div class="search_in">
                <div class="comm_search mr_10">
                    <input type="text" class="input_com" id="srchAuth" name="srchAuth" value="" placeholder="권한그룹명" maxlength="30" style="width: 765px;">
                </div>
                <div class="comm_search ml_40">
                    <div class="search_btn2" id="btnSearchAuthGroup"></div>
                </div>
            </div>
        </div>
        <%--  end of 검색 박스 --%>

        <%--  왼쪽 box  --%>
        <div style="width:45%;">
            <div class="com_box" style="border: 1px solid black; overflow: auto; height: 250px;">
                <table class="tb_list tb_write_02 tb_write_p1">
                    <colgroup>
                        <col style="width:15%">
                        <col style="width:85%">
                    </colgroup>
                    <thead>
                    <tr>
                        <th><input type="checkbox" id="totalAuthCheckAll"></th>
<%--                        <th>권한코드</th>--%>
                        <th>권한그룹 목록</th>
                    </tr>
                    </thead>
                    <tbody id="tdAuthTotal"></tbody>
                </table>
            </div>
        </div>
        <%--  end of 왼쪽 box  --%>

        <%--  화살표 이동  --%>
        <div class="box_w3_2" style="height: 250px;">
            <div class="btn_box">
                <img src="/img/ar_r.png" alt="" id="add_auth"/>
            </div>
            <div class="btn_box">
                <img src="/img/ar_l.png" alt="" id="delete_auth"/>
            </div>
        </div>
        <%--  end of 화살표 이동  --%>

        <%--  오른쪽 box  --%>
        <div style="width:45%;">
            <%--  테이블  --%>
            <div class="com_box" style="border: 1px solid black; overflow: auto; height: 250px;">
                <table class="tb_list tb_write_02 tb_write_p1">
                    <colgroup>
                        <col style="width:15%">
                        <col style="width:85%">
                    </colgroup>
                    <thead>
                    <tr>
                        <th><input type="checkbox" id="userAuthCheckAll"></th>
                        <th>선택된 권한그룹</th>
                    </tr>
                    </thead>
                    <tbody id="tdAuthConf"></tbody>
                </table>
            </div>
        </div>
        <%--  end of 오른쪽 box  --%>

        <div class="c_btnbox center mt_30">
            <div style="display: inline-block;">
                <button type="button" class="comm_btn mr_20" onclick="authConf();">확인</button>
                <button type="button" class="comm_btn" onclick="closePopup('authPickPopup');">취소</button>
            </div>
        </div>
    </div>
</div>
<%--  end of 권한그룹 선택 modal  --%>

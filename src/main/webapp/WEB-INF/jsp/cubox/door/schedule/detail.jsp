<%--
  Created by IntelliJ IDEA.
  User: USER
  Date: 2022-09-02
  Time: 오후 3:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/jsp/cubox/common/checkPasswd.jsp" flush="false"/>
<jsp:include page="/WEB-INF/jsp/cubox/common/doorGroupPickPopup.jsp" flush="false"/> <!-- 출입문 선택 popup -->
<jsp:include page="/WEB-INF/jsp/cubox/common/doorPickPopup.jsp" flush="false"/>

<style>
    .title_box {
        margin-top: 10px;
        margin-bottom: 20px;
    }
    .box {
        border: 1px solid #ccc;
    }
    #tdScheduleDetail tr th {
        text-align: center;
    }
    thead {
        position: sticky;
        top: 0;
    }
    #tdTimePick tr td input {
        width: 125px;
        height: 25px;
        text-align: center;
        margin: 0 auto;
    }
    #tb_Schedule tr td,
    #tb_SchTimepick tr th, #tb_SchTimepick tr td {
        background: none;
    }
    #tb_SchTimepick tr th, #tb_SchTimepick tr td {
        border: none;
    }
    .tb_list tbody tr:nth-child(2n) td {
        background-color: transparent !important;
    }
    .col_days {
        font-weight: bold;
    }
    .colored {
        background-color: coral;
    }
    .sch1_timepick {
        background-color: aliceblue;
    }
    .sch2_timepick {
        background-color: mistyrose;
    }
    .sch3_timepick {
        background-color: floralwhite;
    }
    .sch1 {
        background-color: lightblue;
    }
    .sch2 {
        background-color: lightsalmon;
    }
    .sch3 {
        background-color: gold;
    }
    input[name=timepicker] {
        border: 1px solid gray;
    }
    .btnInit {
        border-radius: 2px;
        float: left;
        border: none;
        padding-left: 15px;
        padding-right: 15px;
    }
    .color_disabled {
        background-color: #eee !important;
        opacity: 1;
    }
</style>

<script type="text/javascript">

    $(function () {
        $(".title_tx").html("출입문 스케쥴 - 상세");
        modalPopup("addByDayPopup", "요일 별 스케쥴 등록", 1590, 915);
        modalPopup("doorGroupPickPopup", "출입문 그룹 선택", 910, 550);
        modalPopup("doorEditPopup", "출입문 선택", 900, 600);

        $("input[type=time]").on({
            change: function () {

                let el = $(this);
                let day = this.id.split("_")[0];
                let schNum = this.id.split("_")[1];
                let ifEnd = this.id.split("_")[2] === "end";
                let startId = "";
                let endId = "";
                let start = {hour: "", min: "", sec: ""};
                let end = {hour: "", min: "", sec: ""};

                if (ifEnd) {
                    console.log("ifEnd");
                    startId = this.id.replace("end", "start");
                    endId = this.id;

                    start.hour = $("#" + startId).val().split(":")[0];
                    start.min = $("#" + startId).val().split(":")[1];
                    start.sec = $("#" + startId).val().split(":")[2];
                    end.hour = el.val().split(":")[0];
                    end.min = el.val().split(":")[1];
                    end.sec = el.val().split(":")[2];

                    if (timeValid(startId, endId, start, end, day, schNum)) {
                        // if end 면 arr와 나머지 start와 비교
                        let arr = $("." + day + "_timepick:not(.sch" + schNum + "_timepick):not(.end)");
                        let mode = '';
                        for (let i = 0; i <= arr.length; i++) {
                            let tmpStart = [];
                            if (arr.eq(i).val() !== "" && arr.eq(i).val() !== undefined) {
                                tmpStart = arr.eq(i).val().split(":");
                                // 초 단위 중복 validation
                                if (end.hour == Number(tmpStart[0]) && end.min == Number(tmpStart[1])) {
                                    console.log("1. hour == min");
                                    if (end.sec < Number(tmpStart[2])) {
                                        console.log("1. 그냥 색칠");
                                        colorSchedule(start, end, day, schNum);
                                        return;
                                    } else if (end.sec >= Number(tmpStart[2])) {
                                        mode = 'S';
                                    }
                                }
                            }
                        }
                        validCheck(mode, startId, endId, start, end, day, schNum);
                        activeNextTimepicker(day, schNum);
                    }

                } else {
                    console.log("ifStart");
                    startId = this.id;
                    endId = this.id.replace("start", "end");

                    start.hour = el.val().split(":")[0];
                    start.min = el.val().split(":")[1];
                    start.sec = el.val().split(":")[2];
                    end.hour = $("#" + endId).val().split(":")[0];
                    end.min = $("#" + endId).val().split(":")[1];
                    end.sec = $("#" + endId).val().split(":")[2];

                    if (timeValid(startId, endId, start, end, day, schNum)) {
                        // if end 아니면 arr와 나머지 end와 시간 비교
                        let arr = $("." + day + "_timepick:not(.sch" + schNum + "_timepick):not(.start)");
                        let mode = '';
                        for (let i = 0; i <= arr.length; i++) {
                            let tmpEnd = [];
                            if (arr.eq(i).val() !== "" && arr.eq(i).val() !== undefined) {
                                tmpEnd = arr.eq(i).val().split(":");
                                // 초 단위 중복 validation
                                if (start.hour == Number(tmpEnd[0]) && start.min == Number(tmpEnd[1])) {
                                    console.log("2. hour == min");
                                    if (start.sec > Number(tmpEnd[2])) {
                                        console.log("2. 그냥 색칠");
                                        colorSchedule(start, end, day, schNum);
                                        return;
                                    } else if (start.sec <= Number(tmpEnd[2])) {
                                        mode = 'S';
                                    }
                                }
                            }
                        }
                        validCheck(mode, startId, endId, start, end, day, schNum);
                    }
                }
            }
        });
        setDoorGroupInfo();
        fnDayExistsCountAjax();
    });

    // 요일 별 스케쥴 있는지 여부 확인
    function fnDayExistsCountAjax() {
        $.ajax({
            type : "GET",
            data : { doorSchId: ${doorScheduleDetail.id} },
            dataType : "json",
            url : "<c:url value='/door/schedule/day/existsCount.do'/>",
            success : function(result) {
                let schCnt = result.getDayScheduleExistsCount;
                console.log("fnDayExistsCountAjax = " + schCnt);

                if (schCnt !== 0) {
                    // 요일 별 스케쥴 보기 버튼
                    $("#btnAddByDay").html("요일 별 스케쥴 보기");
                    $("#btnDaySchDetail").css("display", "block");
                    $("#btnDaySchAdd").css("display", "none");
                    $("#daySchCnt").val(schCnt); // 0 or 21
                } else {
                    // 요일 별 스케쥴 등록 버튼
                    $("#btnAddByDay").html("요일 별 스케쥴 등록");
                    $("#btnDaySchDetail").css("display", "none");
                    $("#btnDaySchAdd").css("display", "block");
                    $(".sch1_timepick").prop("disabled", false);
                    $("#daySchCnt").val(0);
                }
            }
        });
    }

    // 출입문 그룹 정보 set
    function setDoorGroupInfo() {
        let doorGrList = [];
        let doorGrHtml = [];
        <c:forEach items="${schDoorGroupList}" var="dList">
        doorGrList.push(${dList.id});
        doorGrHtml.push('${dList.nm}');
        </c:forEach>
        $("#doorIds").val(doorGrList.join("/"));
        $("#doorGroup").val(doorGrHtml.join("\r\n"));
    }

    // time선택 초기화
    function initTimepicker(start, end) {
        $("#" + start).val("");
        $("#" + end).val("");
    }

    // 색칠 초기화
    function initColor(day, schNum) {
        let editSch = $("." + day + "_" + schNum);

        if (editSch.length != 0) {
            for (let i in editSch) {
                if (i == 0) editSch.eq(i).val("");
                if (i == editSch.length - 1) editSch.eq(i).val("");

                editSch.eq(i).removeClass("colored");
                editSch.eq(i).removeClass("sch" + schNum);
                editSch.eq(i).removeClass(day + "_" + schNum);
            }
        }
    }

    function validCheck(mode, startId, endId, start, end, day, schNum) {
        if (ifValid(mode, startId, endId, start, end, day, schNum)) {
            colorSchedule(start, end, day, schNum);

        } else {
            alert("중복된 스케쥴이 존재합니다. 다시 선택해주세요.");
        }
    }


    // 이미 색칠되어 있는지 여부확인
    function ifValid(mode, startId, endId, start, end, day, schNum) {
        console.log("mode == " + mode);

        let result = true; // 다른 스케쥴과 겹치는지 여부
        if (mode === "S") result = false;

        // while (result) {
        if (result) {
            if (start.hour != end.hour) { // 시작시간과 종료시간이 다른 hour 칸에 있을 때
                for (let i = Number(start.hour); i <= Number(end.hour); i++) {

                    if (i == Number(start.hour)) { // 시작 hour 칸
                        for (let j = Number(start.min); j < 60; j++) {
                            let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2)); // 색칠할 div
                            if ((divToColor.hasClass("colored")) && (!divToColor.hasClass(day + "_" + schNum))) {
                                console.log("1. 색칠되어있고 같은 스케쥴 아님"); ///// 걸리는 애가 시작인 경우
                                result = false;
                                // result = false;
                                break;
                            }
                        }
                    } else if (i == end.hour) { // 종료 hour 칸
                        for (let j = 0; j <= Number(end.min); j++) {
                            let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2)); // 색칠할 div
                            if ((divToColor.hasClass("colored")) && (!divToColor.hasClass(day + "_" + schNum))) {
                                console.log("2. 색칠되어있고 같은 스케쥴 아님");
                                result = false;
                                // result = false;
                                break;
                            }
                        }
                    } else {
                        for (let j = 0; j < 60; j++) {
                            let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2)); // 색칠할 div
                            if ((divToColor.hasClass("colored")) && (!divToColor.hasClass(day + "_" + schNum))) {
                                console.log("3. 색칠되어있고 같은 스케쥴 아님");
                                result = false;
                                // result = false;
                                break;
                            }
                        }
                    }
                }

            } else if (start.hour == end.hour) {  // 시작시간과 종료시간이 같은 hour 칸에 있을 때
                for (let i = Number(start.hour); i <= Number(end.hour); i++) {
                    for (let j = Number(start.min); j <= Number(end.min); j++) {
                        let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2)); // 색칠할 div
                        if ((divToColor.hasClass("colored")) && (!divToColor.hasClass(day + "_" + schNum))) {
                            console.log("4. 색칠되어있고 같은 스케쥴 아님");
                            result = false;
                            // result = false;
                            break;
                        }
                    }
                }
            }
        }

        if (!result) isFirstReg(day, schNum, startId, endId);
        return result;
    }

    // 최초 등록인지 체크
    function isFirstReg(day, schNum, startId, endId) {
        let isFirst = ($("." + day + "_" + schNum).length > 0) ? false : true;  // 최초등록?

        if (isFirst) {
            console.log("최초 등록");
            let sameDaySch = $("." + day + "_timepick");
            let schTime = [];
            let startVal = $("#" + startId).val();
            // let startVal = $("#" + startId).val().split(":").slice(0, -1).join(":"); // 20:47
            let endVal = $("#" + endId).val();
            // let endVal = $("#" + endId).val().split(":").slice(0, -1).join(":");
            let schTime0, schTime1, schTime2, schTime3;

            // 다른 스케쥴들 schTime에 담기
            for (let i = 0; i < sameDaySch.length; i++) {
                let thisId = sameDaySch.eq(i).attr("id");
                if (thisId.split("_")[1] != schNum) {
                    let isStart = sameDaySch.eq(i).hasClass("start");
                    if ((isStart && $("#" + thisId.replace("start", "end")).val() != "") || (!isStart && $("#" + thisId.replace("end", "start")).val())) {
                        console.log("=다른 스케쥴=");
                        console.log($("#" + thisId).val());
                        schTime.push($("#" + thisId).val());
                    }
                }
            }
            // 있는지 없는지 먼저 확인
            if (!fnIsEmpty(schTime[0])) {
                schTime0 = schTime[0];
            }
            if (!fnIsEmpty(schTime[1])) {
                schTime1 = schTime[1];
            }
            if (!fnIsEmpty(schTime[2])) {
                schTime2 = schTime[2];
            }
            if (!fnIsEmpty(schTime[3])) {
                schTime3 = schTime[3];
            }
            // if (!fnIsEmpty(schTime[0])) {
            //     schTime0 = schTime[0].split(":").slice(0, -1).join(":");
            // }
            // if (!fnIsEmpty(schTime[1])) {
            //     schTime1 = schTime[1].split(":").slice(0, -1).join(":");
            // }
            // if (!fnIsEmpty(schTime[2])) {
            //     schTime2 = schTime[2].split(":").slice(0, -1).join(":");
            // }
            // if (!fnIsEmpty(schTime[3])) {
            //     schTime3 = schTime[3].split(":").slice(0, -1).join(":");
            // }

            if ((startVal <= schTime0 && endVal >= schTime1) || (startVal <= schTime2 && endVal >= schTime3)) {
                // console.log("시작시간, 종료시간 둘다 오버된 시간");
                initTimepicker(startId, endId);
            }

            if ((startVal >= schTime0 && startVal <= schTime1) || (startVal >= schTime2 && startVal <= schTime3)) {
                // console.log("시작시간이 기존의 스케쥴과 겹침");
                $("#" + startId).val("");
            }

            if ((endVal >= schTime0 && endVal <= schTime1) || (endVal >= schTime2 && endVal <= schTime3)) {
                // console.log("종료시간이 기존의 스케쥴과 겹침");
                $("#" + endId).val("");
            }

        } else {
            console.log("이미 같은 시간대에 다른 스케쥴 존재");
            let tmpStart = $("div." + day + "_" + schNum).first().val();
            let tmpEnd = $("div." + day + "_" + schNum).last().val();
            $("#" + startId).val(tmpStart.hour + ":" + tmpStart.min + ":" + tmpStart.sec); // 수정 시
            $("#" + endId).val(tmpEnd.hour + ":" + tmpEnd.min + ":" + tmpEnd.sec);
        }

    }

    // 시간 유효성 체크
    function timeValid(startId, endId, start, end, day, schNum) {
        let result = true;
        let startVal = $("#" + startId).val();
        let endVal = $("#" + endId).val();

        if (startVal == "" && endVal != "") { // 시작 시간 입력 안했을 때
            alert("시작 시간을 먼저 선택해주세요.");
            initTimepicker(startId, endId);
            result = false;

        } else if ((startVal != "" && endVal !== "") && startVal >= endVal) { // 시작 시간이 종료시간보다 클 때

            if (!($("." + day + "_" + schNum).length > 0)) {    // 최초등록
                alert("종료시간이 시작시간보다 빠릅니다.");
                $("#" + endId).val("");
            } else {                                            // 수정 시
                alert("종료시간이 시작시간보다 빠릅니다.");
                let tmpStart = $("div." + day + "_" + schNum).first().val();
                let tmpEnd = $("div." + day + "_" + schNum).last().val();
                $("#" + startId).val(tmpStart.hour + ":" + tmpStart.min + ":" + tmpStart.sec);
                $("#" + endId).val(tmpEnd.hour + ":" + tmpEnd.min + ":" + tmpEnd.sec);
            }
            result = false;
        }
        // console.log("timeValid 결과: " + result);
        return result;
    }

    // 해당 범위 색칠
    function colorSchedule(start, end, day, schNum) {
        initColor(day, schNum);

        if (start.hour != end.hour) {
            for (let i = start.hour; i <= end.hour; i++) {  // hour

                // 분단위 coloring
                if (i == start.hour) { // 시작 hour 칸
                    for (let j = Number(start.min); j < 60; j++) {
                        let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2));
                        if (j == Number(start.min)) divToColor.val(start); // 첫번째 div에 시작시간 value 넣기
                        divToColor.addClass("colored");
                        divToColor.addClass("sch" + schNum);
                        divToColor.addClass(day + "_" + schNum); // mon_2
                    }
                } else if (i == end.hour) { // 종료 hour 칸
                    for (let j = 0; j <= Number(end.min); j++) {
                        let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2));
                        if (j == Number(end.min)) divToColor.val(end); // 마지막 div에 종료시간 value 넣기
                        divToColor.addClass("colored");
                        divToColor.addClass("sch" + schNum);
                        divToColor.addClass(day + "_" + schNum);
                    }
                } else {
                    for (let j = 0; j < 60; j++) {
                        let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2));
                        divToColor.addClass("colored");
                        divToColor.addClass("sch" + schNum);
                        divToColor.addClass(day + "_" + schNum);
                    }
                }
            }

        } else if (start.hour == end.hour) {
            for (let i = Number(start.hour); i <= Number(end.hour); i++) {  // hour

                // 분단위 coloring
                if (i == Number(start.hour)) { // 시작 hour 칸
                    for (let j = Number(start.min); j <= Number(end.min); j++) {
                        let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2));
                        if (j == Number(start.min)) divToColor.val(start); // 첫번째 div에 시작시간 value 넣기
                        if (j == Number(end.min)) divToColor.val(end); // 마지막 div에 종료시간 value 넣기
                        divToColor.addClass("colored");
                        divToColor.addClass("sch" + schNum);
                        divToColor.addClass(day + "_" + schNum); // mon_2
                    }
                }
            }
        }
    }

    // 수정 확인
    function fnSave() {
        // 입력값 유효성 체크
        if (fnIsEmpty($("#schNm").val())) {
            alert ("출입문 스케쥴 명을 입력하세요.");
            $("#schNm").focus(); return;
        }
        if (confirm("출입문 스케쥴을 저장하시겠습니까?")) {
            fnUpdateScheduleAjax();
        } else {
            return;
        }
    }

    // 수정 취소
    function fnCancel() {
        $("#schNm").val('${doorScheduleDetail.door_sch_nm}');
        $("#schUseYn ").val("Y").prop("selected", true);
        setDoorGroupInfo();

        $(".title_tx").html("출입문 스케쥴 - 상세");
        $("#btnboxDetail").css("display", "block");
        $("#btnboxEdit").css("display", "none");
        $("#btnEdit, #btnEditAuth").css("display", "none");
        $("[name=detail]").attr("disabled", true).addClass("color_disabled");
    }

    // 수정 버튼
    function fnEditMode() {
        if (confirm("해당 스케쥴을 수정하시겠습니까?")) {
            $(".title_tx").html("출입문 스케쥴 - 수정");
            $("#btnEdit, #btnEditAuth").css("display", "block");
            $("#btnboxDetail").css("display", "none");
            $("#btnboxEdit").css("display", "block");
            $("[name=detail]").attr("disabled", false).removeClass("color_disabled");
        } else {
            return;
        }
    }

    // 삭제 버튼
    function fnDelete() {
        // 출입문 그룹에 그룹이 있으면,
        if ($("#doorIds").val() !== "") {
            alert("연결된 출입문 그룹을 해제 후 삭제 하시기 바랍니다.");
            return;
        }
        if (!confirm("삭제하시겠습니까?")) {
            return;
        }
        fnDeleteScheduleAjax();
    }

    // 요일별 스케쥴 수정 모드
    function fnDaySchEditMode() {
        $("#btnDaySchEdit").css("display", "block");
        $("#btnDaySchDetail").css("display", "none");
        $("#btnDaySchAdd").css("display", "none");
        activeTimepicker();
    }

    // 요일별 스케쥴 보기 모드
    function fnDaySchDetailMode() {
        $("#btnDaySchDetail").css("display", "block");
        $("#btnDaySchEdit").css("display", "none");
        $("#btnDaySchAdd").css("display", "none");
        inactiveTimepicker();
        fnGetScheduleByDayDetail();
    }

    // 요일별 스케쥴 전체 삭제
    function fnDaySchDelete() {
        if (confirm("전체 스케쥴을 삭제하시겠습니까?")) {
            fnDeleteScheduleByDayAjax();
        } else {
            return;
        }
    }

    // 요일별 스케쥴 데이터 validation
    function fnDaySchValidation(type) {
        const days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];
        const schNums = ["1", "2", "3"];
        let data = [];    // 최종 데이터
        let tmp = [];
        let schSet = {};
        let validCnt = 0; // 시작,종료시간 있는 데이터 카운트, 최대 21

        if (clearPickers('save')) {
            console.log("true");
            $.each($("input[name=timepicker]"), function (i, pick) {
                let pId = $(pick).attr("id");    // mon_1_start
                let weekday = pId.split("_")[0]; // 요일 mon
                let schNum = pId.split("_")[1];  // 스케쥴번호 1

                $.each(days, function (j, day) {
                    $.each(schNums, function (k, num) {
                        if (weekday === day && schNum === num) { // 같은 요일, 같은 번호
                            schSet.id = weekday + "_" + schNum;
                            schSet.weekday = weekday;
                            if ($(pick).hasClass("start")) {
                                schSet.beg_tm = $(pick).val();
                            } else if ($(pick).hasClass("end")) {
                                if ($(pick).val() != "") validCnt += 1;
                                schSet.end_tm = $(pick).val();
                                tmp.push(schSet);
                                if (schNum === "3") {
                                    let sortedTmpData = sortByTime(tmp);
                                    $.each(sortedTmpData, function (l, dt) {
                                        data.push(dt);
                                    });
                                    tmp = [];
                                }
                                schSet = {};
                            }
                        }
                    });
                });
            });
            console.log("fnDaySchValidation type : " + type);
            console.log(data);

            if (validCnt == 0) { // 입력한 스케쥴 하나도 없을 경우
                if (type === "Add") alert("등록한 스케쥴이 없습니다.");
                else if (type === "Update") alert("최소 한 개의 스케쥴이 필요합니다.");
            } else {
                if (type === "Add") fnAddScheduleByDayAjax(data);
                else if (type === "Update") fnModifyScheduleByDayAjax(data);
                $("#daySchCnt").val(validCnt);
            }
        }
    }

    // 요일별 스케쥴 전체 초기화
    function fnDaySchInit() {
        $("input[name=timepicker]").val("");
        $(".sch2_timepick, .sch3_timepick").prop("disabled", true);

        $(".colored").val("");
        $(".colored").removeClass("sch1 sch2 sch3 " +
            "mon_1 mon_2 mon_3 tue_1 tue_2 tue_3 wed_1 wed_2 wed_3 thu_1 thu_2 " +
            "thu_3 fri_1 fri_2 fri_3 sat_1 sat_2 sat_3 sun_1 sun_2 sun_3 colored");
    }

    // 시간 순 정렬
    function sortByTime(data) {
        data.sort(function (a, b) {
            if (a.beg_tm === "" && b.beg_tm !== "") {
                return 1;
            }
            if (a.beg_tm !== "" && b.beg_tm === "") {
                return -1;
            }
            if (a.beg_tm !== "" && b.beg_tm !== "") {
                return a.beg_tm.localeCompare(b.beg_tm);
            }
        });

        return data;
    }

    // start 또는 end 시간만 있는 스케쥴 clear
    function clearPickers(mode) {
        // mode : 'save', 'close'
        // 'save'모드 시에는 완성되지 않은 스케쥴 여부 확인
        // 'close'모드 시에는 완성되지 않은 스케쥴 삭제

        let timeList = $("input[type=time]");
        let isComplete = true; // 완성되지 않은 스케쥴있으면 false
        let tmpList = [];

        for (let i = 0; i <= timeList.length; i++) {
            let isStart = timeList.eq(i).hasClass("start");
            if (isStart) {
                let endId = timeList.eq(i).attr("id").replace("start", "end");
                let endPick = $("#" + endId).val();

                if (timeList.eq(i).val() != "" && endPick == "") { // start 값 있음, end 값 없음
                    if (mode === 'save') {
                        isComplete = false;
                        tmpList.push(timeList.eq(i));
                    } else if (mode === 'close') {
                        timeList.eq(i).val("");
                    }
                } else if (timeList.eq(i).val() == "" && endPick != "") { // start 값 없음, end 값 있음
                    if (mode === 'save') {
                        isComplete = false;
                        tmpList.push($("#" + endId));
                    } else if (mode === 'close') {
                        $("#" + endId).val("");
                    }
                }
            }
        }

        if (mode === 'save' && !isComplete) {
            if (!confirm("완성되지 않은 스케쥴이 있습니다. \n계속 진행하시겠습니까?")) {
                return false;
            } else {
                console.log(tmpList);
                for (let i in tmpList) {
                    console.log($(tmpList[i]).val());
                    $(tmpList[i]).val("");
                }
                return true;
            }
        }

        return isComplete;
    }

    // endPicker 클릭 시 다음 timepicker disable 해제
    function activeNextTimepicker(day, schNum) {
        if (schNum === "1" && $("#" + day + "_2_end").val() === "") {  // 2 스케쥴에 값 없을 때
            $("." + day + "_timepick.sch2_timepick").prop("disabled", false);
        }
        if (schNum === "2" && $("#" + day + "_3_end").val() === "") {  // 3 스케쥴에 값 없을 때
            $("." + day + "_timepick.sch3_timepick").prop("disabled", false);
        }
    }

    // timepicker disable 해제
    function activeTimepicker() {
        $(".sch1_timepick").prop("disabled", false);
        $.each($(".sch2_timepick"), function (i, sch2) {
            let weekday = $(sch2).attr("id").split("_")[0];
            if ($(sch2).val() !== "") {  // 2번 스케쥴에 값이 있을 경우
                $(sch2).prop("disabled", false);
                $("." + weekday + "_timepick.sch3_timepick").prop("disabled", false);
            } else {  // 2번 스케쥴에 값이 없을 경우
                if ($("#" + weekday + "_1_start").val() !== "") {   // 1번 스케줄에 값이 있을 경우
                    $(sch2).prop("disabled", false);
                }
            }
        });
    }

    function inactiveTimepicker() {
        $("input[name=timepicker]").prop("disabled", true);
    }

    // popup open (공통)
    function openPopup(popupNm) {
        $("#" + popupNm).PopupWindow("open");
        if (popupNm === "doorGroupPickPopup") {
            fnGetDoorGroupListAjax();
        } else if (popupNm === "addByDayPopup") {
            fnGetScheduleByDayDetail();
        } else if (popupNm === "doorEditPopup") {
            fnGetDoorListAjax("Schedule");
        }
    }

    // popup close (공통)
    function closePopup(popupNm) {
        $("#" + popupNm).PopupWindow("close");
        if (popupNm === "doorGroupPickPopup") { // 출입문 그룹 선택
            $("input[name=chkGroup]:checked").attr("checked", false);
            $("input[name=chkGroupConf]:checked").attr("checked", false);
            totalCheck();
            userCheck();
        } else if (popupNm === "addByDayPopup") { // 요일별 스케쥴 등록
            clearPickers('close');
        }
    }


    /////////////////  출입문 스케쥴 수정 ajax - start  /////////////////////

    function fnUpdateScheduleAjax() {
        let doorSchNm = $("#schNm").val();
        let useYn = $("#schUseYn").val();
        let doorGroupIds = $("#doorIds").val();
        let url = "<c:url value='/door/schedule/modify/${doorScheduleDetail.id}'/>";

        $.ajax({
            type : "POST",
            data : {
                  doorSchNm: doorSchNm
                , useYn: useYn
                , doorGroupIds: doorGroupIds
            },
            dataType : "json",
            url : url,
            success : function(result) {
                console.log(result);
                if (result.resultCode === "Y") {
                    alert("수정이 완료되었습니다.");
                    window.location.href = '/door/schedule/detail/${doorScheduleDetail.id}';
                } else {
                    console.log(result.resultMsg);
                }
            }
        });
    }

    /////////////////  출입문 스케쥴 수정 ajax - end  /////////////////////


    /////////////////  출입문 스케쥴 삭제 ajax - start  /////////////////////

    function fnDeleteScheduleAjax() {
        $.ajax({
            type: "post",
            url: "/door/schedule/delete/${doorScheduleDetail.id}",
            dataType: 'json',
            success: function (result) {
                if (result.resultCode === "Y") {
                    alert("삭제되었습니다.");
                    location.href = "/door/schedule/list.do";
                } else {
                    alert("삭제 중 오류가 발생하였습니다.");
                }
            }
        });
    }

    /////////////////  출입문 스케쥴 삭제 ajax - end  /////////////////////


    /////////////////  요일별 스케쥴 뿌려주기 ajax - start  /////////////////////

    function fnGetScheduleByDayDetail() {
        console.log("fnGetScheduleByDayDetail");

        $.ajax({
            type : "POST",
            data : {},
            dataType : "json",
            async: false,
            url : "<c:url value='/door/schedule/day/detail/${doorScheduleDetail.id}'/>",
            success : function(result) {
                if (result.resultCode === "Y") {
                    console.log(result.scheduleByDayDetailList);

                    // 1. 초기화
                    fnDaySchInit();

                    // 2. 스케쥴 뿌려주기
                    let cnt = 0; // 데이터가 들어있는 요일 별 스케쥴 갯수
                    $.each(result.scheduleByDayDetailList, function (i, sch) {

                        let beg_tm = sch.beg_tm.split(":");
                        let end_tm = sch.end_tm.split(":");
                        let start = {hour: beg_tm[0], min: beg_tm[1], sec: beg_tm[2]};
                        let end = {hour: end_tm[0], min: end_tm[1], sec: end_tm[2]};
                        let day = sch.weekday_order_no.split("_")[0];
                        let schNum = sch.weekday_order_no.split("_")[1];

                        // timepicker 값 넣기
                        $("#" + sch.weekday_order_no + "_start").val(sch.beg_tm);
                        $("#" + sch.weekday_order_no + "_end").val(sch.end_tm);

                        if (sch.end_tm !== "") cnt ++;
                        colorSchedule(start, end, day, schNum);
                    });

                    $("#daySchCnt").val(cnt);

                }
            }
        });
    }

    /////////////////  요일별 스케쥴 뿌려주기 ajax - end  /////////////////////


    /////////////////  요일별 스케쥴 저장 ajax - start  /////////////////////

    function fnAddScheduleByDayAjax(data) {

        let jsonData = JSON.stringify(data);
        let url = "<c:url value='/door/schedule/day/add.do' />";

        $.ajax({
            type: "POST",
            url: url,
            data:  {
                "doorSchId" : $("#scheduleId").val() ,
                "day_schedule" : jsonData
            },
            dataType: "json",
            success: function (result) {
                console.log(result);

                if (result.resultCode === "Y") {
                    alert("저장되었습니다.");
                    $("#btnAddByDay").html("요일 별 스케쥴 보기");
                    fnDaySchDetailMode();
                } else {
                    alert("등록에 실패하였습니다.");
                }
            }
        });
    }

    /////////////////  요일별 스케쥴 저장 ajax - end  /////////////////////


    /////////////////  요일별 스케쥴 수정 ajax - start  /////////////////////

    function fnModifyScheduleByDayAjax(data) {

        let jsonData = JSON.stringify(data);
        let url = "<c:url value='/door/schedule/day/modify/${doorScheduleDetail.id}' />";

        $.ajax({
            type: "POST",
            url: url,
            data:  {
                "doorSchId" : $("#scheduleId").val() ,
                "day_schedule" : jsonData
            },
            dataType: "json",
            success: function (result) {
                console.log(result);

                if (result.resultCode === "Y") {
                    alert("저장되었습니다.");
                    fnDaySchDetailMode();
                } else {
                    alert("등록에 실패하였습니다.");
                }
            }
        });
    }

    /////////////////  요일별 스케쥴 수정 ajax - end  /////////////////////


    /////////////////  요일별 스케쥴 전체 삭제 ajax - start  /////////////////////

    function fnDeleteScheduleByDayAjax() {

        let url = "<c:url value='/door/schedule/day/delete/${doorScheduleDetail.id}' />";

        $.ajax({
            type: "POST",
            url: url,
            dataType: "json",
            success: function (result) {
                console.log(result);
                if (result.resultCode === "Y") {
                    alert("삭제되었습니다.");
                    fnDaySchInit();
                    $("#btnAddByDay").html("요일 별 스케쥴 등록");
                    $("#btnDaySchAdd").css("display", "block");
                    $("#btnDaySchDetail").css("display", "none");
                    $("#btnDaySchEdit").css("display", "none");
                    $(".sch1_timepick").prop("disabled", false);
                    $("#daySchCnt").val(0);
                } else {
                    alert("삭제에 실패하였습니다.");
                }
            }
        });
    }

    /////////////////  요일별 스케쥴 전체 삭제 ajax - end  /////////////////////


</script>

<form id="detailForm" name="detailForm" method="post" enctype="multipart/form-data">
    <div class="tb_01_box">
        <table class="tb_write_02 tb_write_p1 box">
            <colgroup>
                <col style="width:10%">
                <col style="width:90%">
            </colgroup>
            <tbody id="tdScheduleDetail">
            <input type="hidden" id="scheduleId" value="${doorScheduleDetail.id}">
            <input type="hidden" id="daySchCnt" value="0">
            <input type="hidden" id="doorIds" value="">
            <tr>
                <th>출입문 스케쥴 명</th>
                <td>
                    <input type="text" id="schNm" name="detail" maxlength="35" size="50" value="${doorScheduleDetail.door_sch_nm}"
                           class="w_600px input_com color_disabled" onkeyup="charCheck(this)" onkeydown="charCheck(this)" disabled>
                </td>
            </tr>
            <tr>
                <th>사용</th>
                <td>
                    <select id="schUseYn" name="detail" class="form-control w_600px color_disabled" style="padding-left:10px;" disabled>
                        <option value="" name="selected">선택</option>
                        <option value="Y" <c:if test="${doorScheduleDetail.use_yn eq 'Y'}" >selected </c:if>>사용</option>
                        <option value="N" <c:if test="${doorScheduleDetail.use_yn eq 'N'}" >selected </c:if>>미사용</option>
                    </select>
                </td>
            </tr>
<%--            <tr>--%>
<%--                <th>출입문 그룹</th>--%>
<%--                <td style="display: flex;">--%>
<%--                    <textarea id="doorGroup" name="doorGroup" rows="10" cols="33" class="w_600px color_disabled" style="border-color: #ccc; border-radius: 2px;--%>
<%--                              font-size: 14px; line-height: 1.5; padding: 2px 10px;" disabled></textarea>--%>
<%--                    <div class="ml_10" style="position:relative;">--%>
<%--                        <button id="btnEdit" type="button" class="btn_small color_basic" onclick="openPopup('doorGroupPickPopup')" style="width:60px; position:absolute; bottom:0; display:none;">선택</button>--%>
<%--                    </div>--%>
<%--                </td>--%>
<%--            </tr>--%>
            <tr style="display:none;">
                <th>출입문</th>
                <td style="display: flex;">
                    <textarea id="schDoorNms" name="schDoorNms" rows="10" cols="33" class="w_600px color_disabled" style="border-color: #ccc; border-radius: 2px;
                              font-size: 14px; line-height: 1.5; padding: 2px 10px;" disabled><c:set var="nm" value="${fn:split(doorScheduleDetail.door_nms,'/')}" /><c:forEach items="${nm}" var="dName" varStatus="varStatus">
${dName}</c:forEach></textarea>
                    <div class="ml_10" style="position: relative;">
                        <button id="btnEdit" type="button" class="btn_small color_basic" style="position: absolute; bottom: 0; width: 60px; display: none;" onclick="openPopup('doorEditPopup')">선택</button>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</form>

<div class="right_btn mt_20" id="btnboxDetail">
    <button class="btn_middle color_basic" onclick="location='/door/schedule/list.do'">목록</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnEditMode();">수정</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnDelete();">삭제</button>
    <button class="btn_middle ml_10 color_color1" id="btnAddByDay" onclick="openPopup('addByDayPopup');">요일 별 스케쥴 등록</button>
</div>
<div class="right_btn mt_20" id="btnboxEdit" style="display:none;">
    <button class="btn_middle color_basic" onclick="fnSave();">저장</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnCancel();">취소</button>
</div>

<%--  요일 별 스케쥴 등록 modal  --%>
<div id="addByDayPopup" class="example_content" style="display: none;">
    <c:set var="days" value="${fn:split('월,화,수,목,금,토,일',',')}"/>
    <c:set var="days_eng" value="${fn:split('mon,tue,wed,thu,fri,sat,sun',',')}"/>
    <div id="popupContent" class="popup_box box_w3" style="margin-top:0px; padding:20px;">
        <%--  검색 박스 --%>
        <div class="search_box">
            <div class="search_in">
                <div class="comm_search mr_10">
                    <label for="srchschNm" class="mr_10">출입문 스케쥴 명</label>
                    <input type="text" class="w_600px input_com" id="srchschNm" name="srchschNm" value="${doorScheduleDetail.door_sch_nm}" maxlength="30" disabled>
                </div>
            </div>
        </div>
        <%--  end of 검색 박스 --%>

        <%--  왼쪽 box  --%>
        <div class="mt_20" style="width:73%;">
            <div class="com_box" style="border:1px solid black;">
                <table class="tb_list" id="tb_Schedule" style="height:665px;">
                    <colgroup>
                        <c:forEach var="i" begin="0" end="24" varStatus="status">
                            <col style="width:3%">
                        </c:forEach>
                    </colgroup>
                    <thead>
                    <tr>
                        <th>구분</th>
                        <c:forEach var="i" begin="0" end="23" varStatus="status">
                            <fmt:formatNumber var="no" minIntegerDigits="2" value="${status.index}" type="number"/>
                            <th>${no}</th>
                        </c:forEach>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${days}" var="day" varStatus="status">
                        <c:set var="day_eng" value="${days_eng[status.index]}"></c:set>
                        <tr>
                            <td class="col_days" style="background-color:#EAECF0 !important;">${day}</td>
                            <c:forEach var="j" begin="0" end="23" varStatus="status">
                                <fmt:formatNumber var="no" minIntegerDigits="2" value="${status.index}" type="number"/>
                                <td>
                                    <div name="timeline" class="timeline_${day_eng}${no}" style="height:50%;display:flex;flex-wrap:wrap;">
                                        <c:forEach var="min" begin="0" end="59" varStatus="status">
                                            <fmt:formatNumber var="min" minIntegerDigits="2" value="${status.index}" type="number"/>
                                            <div name="timeline" class="timeline_${day_eng}${no}_${min}" style="height:100%;flex-basis:1.666%;"></div>
                                        </c:forEach>
                                    </div>
                                </td>
                            </c:forEach>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
        <%--  end of 왼쪽 box  --%>

        <%--  오른쪽 box  --%>
        <div class="mt_20" style="width:26%;">
            <%--  테이블  --%>
            <div class="com_box">
                <table id="tb_SchTimepick" class="tb_list" style="height:665px;">
                    <colgroup>
                        <c:forEach var="i" begin="0" end="2" varStatus="status">
                            <col style="width:33%">
                        </c:forEach>
                    </colgroup>
                    <thead>
                    <tr class="colorTheme">
                        <th style="color: transparent !important; background-color: lightblue; padding:0; border:10px solid transparent !important;">-</th>
                        <th style="color: transparent !important; background-color: lightsalmon; padding:0; border:10px solid transparent !important;">-</th>
                        <th style="color: transparent !important; background-color: gold; padding:0; border:10px solid transparent !important;">-</th>
                    </tr>
                    </thead>
                    <tbody id="tdTimePick">
                    <form id="formSchedule" name="formSchedule">
                        <c:forEach var="day" items="${days_eng}" varStatus="status">
                            <tr>
                                <c:forEach begin="1" end="3" varStatus="status">
                                    <fmt:formatNumber var="no" value="${status.index}" type="number"/>
                                    <td>
                                        <input type="time" id="${day}_${no}_start" name="timepicker" class="start ${day}_timepick sch${no}_timepick" value="" min="00:00:00" max="23:59:59" step="1" disabled><br>~
                                        <input type="time" id="${day}_${no}_end" name="timepicker" class="end ${day}_timepick sch${no}_timepick" value="" min="00:00:00" max="23:59:59" step="1" disabled>
                                    </td>
                                </c:forEach>
                            </tr>
                        </c:forEach>
                    </form>
                    </tbody>
                </table>
            </div>
        </div>
        <%--  end of 오른쪽 box  --%>

        <div class="c_btnbox center mt_20" id="btnDaySchDetail">
            <div style="display: inline-block;">
                <button type="button" class="comm_btn mr_20" onclick="fnDaySchEditMode();">수정</button>
                <button type="button" class="comm_btn" onclick="closePopup('addByDayPopup');">닫기</button>
            </div>
        </div>
        <div class="c_btnbox center mt_20" id="btnDaySchEdit" style="display: none;">
            <div style="display: inline-block;">
                <button type="button" class="btn_gray3 btn_middle mr_20 btnInit" onclick="fnDaySchInit();">초기화</button>
                <button type="button" class="comm_btn mr_20" onclick="fnDaySchValidation('Update');">저장</button>
                <button type="button" class="comm_btn mr_20" onclick="fnDaySchDelete();">삭제</button>
                <button type="button" class="comm_btn" onclick="fnDaySchDetailMode();">취소</button>
            </div>
        </div>
        <div class="c_btnbox center mt_20" id="btnDaySchAdd">
            <div style="display: inline-block;">
                <button type="button" class="btn_gray3 btn_middle mr_20 btnInit" onclick="fnDaySchInit();">초기화</button>
                <button type="button" class="comm_btn mr_20" onclick="fnDaySchValidation('Add');">저장</button>
                <button type="button" class="comm_btn" onclick="closePopup('addByDayPopup');">닫기</button>
            </div>
        </div>
    </div>
</div>
<%--  end of 권한그룹 선택 modal  --%>


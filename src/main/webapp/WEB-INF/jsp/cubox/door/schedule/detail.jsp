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
</style>

<script type="text/javascript">

    // let tmp = [
    //     {id: "mon_1", weekday: "mon", beg_tm: "13:00:27", end_tm: "13:40:30"},
    //     {id: "mon_2", weekday: "mon", beg_tm: "13:45:00", end_tm: "18:00:30"},
    //     {id: "mon_3", weekday: "mon", beg_tm: "", end_tm: ""},
    //     {id: "tue_1", weekday: "tue", beg_tm: "13:00:00", end_tm: "15:00:00"},
    //     {id: "tue_2", weekday: "tue", beg_tm: "19:40:27", end_tm: "22:00:20"},
    //     {id: "tue_3", weekday: "tue", beg_tm: "", end_tm: ""},
    //     {id: "wed_1", weekday: "wed", beg_tm: "01:50:00", end_tm: "08:20:30"},
    //     {id: "wed_2", weekday: "wed", beg_tm: "08:40:00", end_tm: "12:00:00"},
    //     {id: "wed_3", weekday: "wed", beg_tm: "13:40:50", end_tm: "23:59:59"},
    //     {id: "thu_1", weekday: "thu", beg_tm: "", end_tm: ""},
    //     {id: "thu_2", weekday: "thu", beg_tm: "", end_tm: ""},
    //     {id: "thu_3", weekday: "thu", beg_tm: "", end_tm: ""},
    //     {id: "fri_1", weekday: "fri", beg_tm: "10:30:00", end_tm: "19:30:00"},
    //     {id: "fri_2", weekday: "fri", beg_tm: "", end_tm: ""},
    //     {id: "fri_3", weekday: "fri", beg_tm: "", end_tm: ""},
    //     {id: "sat_1", weekday: "sat", beg_tm: "07:00:00", end_tm: "16:30:30"},
    //     {id: "sat_2", weekday: "sat", beg_tm: "17:40:20", end_tm: "20:20:00"},
    //     {id: "sat_3", weekday: "sat", beg_tm: "", end_tm: ""},
    //     {id: "sun_1", weekday: "sun", beg_tm: "01:00:00", end_tm: "23:59:59"},
    //     {id: "sun_2", weekday: "sun", beg_tm: "", end_tm: ""},
    //     {id: "sun_3", weekday: "sun", beg_tm: "", end_tm: ""}
    // ];

    $(function () {
        $(".title_tx").html("출입문 스케쥴 - 상세");
        modalPopup("addByDayPopup", "요일 별 스케쥴 등록", 1590, 915);
        modalPopup("doorGroupPickPopup", "출입문 그룹 선택", 910, 550);

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

                    activeNextTimepicker(day, schNum);

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
                }

                if (timeValid(startId, endId, start, end, day, schNum)) {
                    validCheck(startId, endId, start, end, day, schNum);
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
                    console.log("요일 별 스케쥴이 있음");
                    // 요일 별 스케쥴 보기 버튼
                    $("#btnAddByDay").html("요일 별 스케쥴 보기");
                    $("#btnDaySchDetail").css("display", "block");
                    $("#btnDaySchAdd").css("display", "none");
                    $("#daySchCnt").val(schCnt);
                } else {
                    console.log("요일 별 스케쥴이 없음");
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
        console.log("setDoorGroupInfo");
        let doorGrList = [];
        let doorGrHtml = [];
        <c:forEach items="${doorGroupList}" var="dList">
        doorGrList.push(${dList.id});
        doorGrHtml.push('${dList.nm}');
        </c:forEach>
        $("#doorIds").val(doorGrList.join("/"));
        $("#doorGroup").val(doorGrHtml.join("\r\n"));
        console.log($("#doorGroup").val());
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

    function validCheck(startId, endId, start, end, day, schNum) {
        if (ifValid(startId, endId, start, end, day, schNum)) {
            console.log("색칠하기_ifEnd");
            colorSchedule(start, end, day, schNum);

        } else {
            console.log("색칠안하기_ifEnd");
            alert("중복된 스케쥴이 존재합니다. 다시 선택해주세요.");
        }
    }

    // 이미 색칠되어 있는지 여부확인
    function ifValid(startId, endId, start, end, day, schNum) {
        console.log("ifValid");
        let result = true; // 다른 스케쥴과 겹치는지 여부

        if (start.hour != end.hour) { // 시작시간과 종료시간이 다른 hour 칸에 있을 때
            for (let i = Number(start.hour); i <= Number(end.hour); i++) {

                if (i == Number(start.hour)) { // 시작 hour 칸
                    for (let j = Number(start.min); j < 60; j++) {
                        let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2)); // 색칠할 div
                        if ((divToColor.hasClass("colored")) && (!divToColor.hasClass(day + "_" + schNum))) {
                            console.log("1. 색칠되어있고 같은 스케쥴 아님"); ///// 걸리는 애가 시작
                            // 칠하고자 하는 시작점과 지금 확인중인 시작점 비교
                            result = false;
                            break;
                        }
                    }
                } else if (i == end.hour) { // 종료 hour 칸
                    for (let j = 0; j <= Number(end.min); j++) {
                        let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2)); // 색칠할 div
                        if ((divToColor.hasClass("colored")) && (!divToColor.hasClass(day + "_" + schNum))) {
                            console.log("2. 색칠되어있고 같은 스케쥴 아님");
                            result = false;
                            break;
                        }
                    }
                } else {
                    for (let j = 0; j < 60; j++) {
                        let divToColor = $(".timeline_" + day + ("00" + i).slice(-2) + "_" + ("00" + j).slice(-2)); // 색칠할 div
                        if ((divToColor.hasClass("colored")) && (!divToColor.hasClass(day + "_" + schNum))) {
                            console.log("3. 색칠되어있고 같은 스케쥴 아님");
                            result = false;
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
                        break;
                    }
                }
            }
        }

        if (!result) isFirstReg(day, schNum, startId, endId);

        console.log("ifValid 결과: " + result);
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
            let endVal = $("#" + endId).val();

            // 다른 스케쥴들 schTime에 담기
            for (let i = 0; i < sameDaySch.length; i++) {
                let thisId = sameDaySch.eq(i).attr("id");
                if (thisId.split("_")[1] != schNum) {
                    console.log("=다른 스케쥴=");
                    console.log($("#" + thisId).val());

                    let isStart = sameDaySch.eq(i).hasClass("start");
                    if ((isStart && $("#" + thisId.replace("start", "end")).val() != "") || (!isStart && $("#" + thisId.replace("end", "start")).val())) {
                        schTime.push($("#" + thisId).val());
                    }
                }
            }
            console.log(schTime);

            if ((startVal <= schTime[0] && endVal >= schTime[1]) || (startVal <= schTime[2] && endVal >= schTime[3])) {
                console.log("둘다 오버된 시간");
                initTimepicker(startId, endId);
            }

            if ((startVal >= schTime[0] && startVal <= schTime[1]) || (startVal >= schTime[2] && startVal <= schTime[3])) {
                console.log("시작시간 겹침");
                $("#" + startId).val("");
            }

            if ((endVal >= schTime[0] && endVal <= schTime[1]) || (endVal >= schTime[2] && endVal <= schTime[3])) {
                console.log("종료시간 겹침");
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
                console.log("timevalid 최초등록");
                alert("종료시간이 시작시간보다 빠릅니다.");
                $("#" + endId).val("");
            } else {                                            // 수정 시
                console.log("timevalid 최초등록 아님");
                alert("종료시간이 시작시간보다 빠릅니다.");
                let tmpStart = $("div." + day + "_" + schNum).first().val();
                let tmpEnd = $("div." + day + "_" + schNum).last().val();
                $("#" + startId).val(tmpStart.hour + ":" + tmpStart.min + ":" + tmpStart.sec);
                $("#" + endId).val(tmpEnd.hour + ":" + tmpEnd.min + ":" + tmpEnd.sec);
            }
            result = false;
        }
        console.log("timeValid 결과: " + result);
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

        fnUpdateScheduleAjax();
    }

    // 수정 취소
    function fnCancel() {
        console.log("fnCancel");
        // $("#detailForm").load(location.href + ' #detailForm');
        $("#schNm").val('${doorScheduleDetail.door_sch_nm}');
        $("#schUseYn ").val("Y").prop("selected", true);
        setDoorGroupInfo();

        $(".title_tx").html("출입문 스케쥴 - 상세");
        $("#btnboxDetail").css("display", "block");
        $("#btnboxEdit").css("display", "none");
        $("#btnEdit").css("display", "none");
        $("[name=detail]").attr("disabled", true);
    }

    // 수정 버튼
    function fnEditMode() {
        $(".title_tx").html("출입문 스케쥴 - 수정");
        $("#btnEdit").css("display", "block");
        $("#btnboxDetail").css("display", "none");
        $("#btnboxEdit").css("display", "block");
        $("[name=detail]").attr("disabled", false);
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
    }

    // 요일별 스케쥴 전체 삭제
    function fnDaySchDelete() {
        if (confirm("전체 스케쥴을 삭제하시겠습니까?")) {
            // TODO: 삭제 ajax
        } else {
            return;
        }
    }

    // 요일별 스케쥴 수정 저장
    function fnDaySchModify() {
        console.log("fnDaySchModify");
        let data = fnDaySchValidation();

        console.log(data);
        console.log(data.length);

        if (!data) {
            alert("등록할 스케쥴이 없습니다.");
        } else {
            fnModifyScheduleByDayAjax(data);
        }

    }

    // 요일별 스케쥴 데이터 validation
    function fnDaySchValidation() {
        const days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];
        const schNums = ["1", "2", "3"];
        let data = [];    // 최종 데이터
        let tmp = [];
        let schSet = {};
        let validCnt = 0; // 시작,종료시간 있는 데이터 카운트, 최대 21

        clearPickers();
        // closePopup("addByDayPopup");

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

        console.log("validation data");
        console.log(data);
        console.log("validation count = " + validCnt);
        $("#daySchCnt").val(validCnt);

        if (validCnt == 0) { // 입력한 스케쥴 하나도 없을 경우
            return false;
        } else {
            $("#daySchCnt").val(validCnt);
            return data;
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

        // $("div[class*=sch]")
    }

    // 요일별 스케쥴 등록
    function fnDaySchSave() {
        console.log("fnDaySchSave");
        let data = fnDaySchValidation();

        if (!data) {
            alert("등록할 스케쥴이 없습니다.");
        } else {
            if (confirm("저장하시겠습니까?")) {
                fnAddScheduleByDayAjax(data);
            }
            return;
        }
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
    function clearPickers() {
        let timeList = $("input[type=time]");
        for (let i = 0; i <= timeList.length; i++) {
            let isStart = timeList.eq(i).hasClass("start");
            if (isStart) {
                let endId = timeList.eq(i).attr("id").replace("start", "end");
                let endPick = $("#" + endId).val();

                if (timeList.eq(i).val() != "" && endPick == "") { // start 값 있음, end 값 없음
                    console.log("startVal 있음, endVal 없음");
                    timeList.eq(i).val("");
                } else if (timeList.eq(i).val() == "" && endPick != "") { // start 값 없음, end 값 있음
                    console.log("startVal 없음, endVal 있음");
                    $("#" + endId).val("");
                }
            }
        }
    }

    // endPicker 클릭 시 다음 timepicker disable 해제
    function activeNextTimepicker(day, schNum) {
        if (schNum === "1" && $("#" + day + "_2_end").val() === "") {  // 2 스케쥴에 값 없을 때
            console.log("1클릭");
            $("." + day + "_timepick.sch2_timepick").prop("disabled", false);
        }
        if (schNum === "2" && $("#" + day + "_3_end").val() === "") {  // 3 스케쥴에 값 없을 때
            console.log("2클릭");
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
                // $("#" + weekday + "_3_start").prop("disabled", false);
                // $("#" + weekday + "_3_end").prop("disabled", false);
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
            if ($("#daySchCnt").val() != 0) {
                // 연결된 스케쥴 있음
                //
            } else {
                // 연결된 스케쥴 없음, 등록 가능
            }
            fnGetScheduleByDayDetail();
            // activeTimepicker();
        }
    }

    // popup close (공통)
    function closePopup(popupNm) {
        console.log("close popup");
        $("#" + popupNm).PopupWindow("close");
        if (popupNm === "doorGroupPickPopup") { // 출입문 그룹 선택
            $("input[name=chkGroup]:checked").attr("checked", false);
            $("input[name=chkGroupConf]:checked").attr("checked", false);
            totalCheck();
            userCheck();
        } else if (popupNm === "addByDayPopup") { // 요일별 스케쥴 등록
            clearPickers();
        }
    }


    /////////////////  출입문 스케쥴 수정 ajax - start  /////////////////////

    function fnUpdateScheduleAjax() {
        let doorSchNm = $("#schNm").val();
        let useYn = $("#schUseYn").val();
        let doorGroupIds = $("#doorIds").val();
        let url = "<c:url value='/door/schedule/modify/${doorScheduleDetail.id}'/>";

        console.log(doorSchNm);
        console.log(useYn);
        console.log(doorGroupIds);
        console.log(url);

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
                    console.log("스케쥴 수정 실패");
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
            success: function (result, status) {
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

        $.ajax({
            type : "POST",
            data : {},
            dataType : "json",
            async: false,
            url : "<c:url value='/door/schedule/day/detail/${doorScheduleDetail.id}'/>",
            success : function(result) {
                if (result.resultCode === "Y") {
                    console.log(result.scheduleByDayDetailList.length);
                    console.log(result.scheduleByDayDetailList);
                    let cnt = 0;

                    // 스케쥴 뿌려주기
                    $.each(result.scheduleByDayDetailList, function (i, sch) {

                        let beg_tm = sch.beg_tm.split(":");
                        let end_tm = sch.end_tm.split(":");
                        let start = {hour: beg_tm[0], min: beg_tm[1], sec: beg_tm[2]};
                        let end = {hour: end_tm[0], min: end_tm[1], sec: end_tm[2]};
                        let day = sch.weekday_order_no.split("_")[0];
                        let schNum = sch.weekday_order_no.split("_")[1];
                        // let day = sch.weekday;
                        // let schNum = sch.id.split("_")[1];
                        // timepicker 값 넣기
                        $("#" + sch.weekday_order_no + "_start").val(sch.beg_tm);
                        $("#" + sch.weekday_order_no + "_end").val(sch.end_tm);
                        if (sch.end_tm !== "") cnt ++;
                        // $("#" + sch.id + "_start").val(sch.beg_tm);
                        // $("#" + sch.id + "_end").val(sch.end_tm);
                        colorSchedule(start, end, day, schNum);
                    });

                    console.log(cnt);
                    $("#daySchCnt").val(cnt);

                } else {
                    console.log("스케쥴 불러오기 실패");
                }
            }
        });



    }

    /////////////////  요일별 스케쥴 뿌려주기 ajax - end  /////////////////////


    /////////////////  요일별 스케쥴 저장 ajax - start  /////////////////////

    function fnAddScheduleByDayAjax(data) {
        console.log("fnAddSchedule");
        let jsonData = JSON.stringify(data);
        let url = "<c:url value='/door/schedule/day/add.do' />";
        console.log(jsonData);
        console.log(url);

        $.ajax({
            type: "POST",
            url: url,
            data:  {
                "doorSchId" : $("#scheduleId").val() ,
                "day_schedule" : jsonData
            },
            dataType: "json",
            success: function (result) {
                console.log("schedule-day-add-ajax");
                console.log(result);

                if (result.resultCode === "Y") {
                    alert("저장되었습니다.");
                    $("#btnAddByDay").html("요일 별 스케쥴 보기");
                    // $("#daySchCnt").val(schCnt);
                    fnDaySchDetailMode();
                } else {
                    //등록에 문제가 발생
                    alert("등록에 실패하였습니다.");
                }
            }
        });
    }

    /////////////////  요일별 스케쥴 저장 ajax - end  /////////////////////


    /////////////////  요일별 스케쥴 수정 ajax - start  /////////////////////

    function fnModifyScheduleByDayAjax(data) {
        console.log("fnModifySchedule");
        let jsonData = JSON.stringify(data);
        let url = "<c:url value='/door/schedule/day/modify/${doorScheduleDetail.id}' />";

        console.log(jsonData);
        console.log(url);

        $.ajax({
            type: "POST",
            url: url,
            data:  {
                "doorSchId" : $("#scheduleId").val() ,
                "day_schedule" : jsonData
            },
            dataType: "json",
            success: function (result) {
                console.log("schedule-day-modify-ajax");
                console.log(result);

                if (result.resultCode === "Y") {
                    alert("저장되었습니다.");
                    fnDaySchDetailMode();
                } else {
                    //등록에 문제가 발생
                    alert("등록에 실패하였습니다.");
                }
            }
        });
    }

    /////////////////  요일별 스케쥴 수정 ajax - end  /////////////////////



    <%--/////////////////  출입문 그룹 조회 ajax - start  /////////////////////--%>

    <%--function fnGetDoorGroupListAjax() {--%>
    <%--    $.ajax({--%>
    <%--        type: "POST",--%>
    <%--        url: "<c:url value='/door/schedule/group/listAjax.do' />",--%>
    <%--        data:  {--%>
    <%--            "doorSchId" : $("#scheduleId").val()--%>
    <%--        },--%>
    <%--        dataType: "json",--%>
    <%--        success: function (result) {--%>
    <%--            console.log(result);--%>
    <%--            $("#tdGroupTotal").empty();--%>
    <%--            $("#tdGroupConf").empty();--%>

    <%--            if (result.doorGroupList.length > 0) {--%>
    <%--                $.each(result.doorGroupList, function (l, dList) {--%>
    <%--                    let html = "<tr><td style='padding:0 14px;'><input type='checkbox' name='chkGroup' value='" + dList.id + "'></td>";--%>
    <%--                    html += "<td>" + dList.id + "</td>";--%>
    <%--                    html += "<td>" + dList.nm + "</td></tr>";--%>
    <%--                    $("#tdGroupTotal").append(html);--%>
    <%--                });--%>

    <%--                console.log($("#doorIds").val());--%>
    <%--                if ($("#doorIds").val() !== "") {--%>
    <%--                    let doorIds = $("#doorIds").val().split("/");--%>
    <%--                    $.each(doorIds, function(i, doorId) {--%>
    <%--                        $('input[name=chkGroup]:input[value=' + doorId + ']').prop("checked", true);--%>
    <%--                        $("#add_group").click();--%>
    <%--                    })--%>
    <%--                }--%>
    <%--            }--%>
    <%--        }--%>
    <%--    });--%>
    <%--}--%>

    <%--/////////////////  출입문 그룹 조회 ajax - end  /////////////////////--%>

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

<%--            <c:forEach items="${doorGroupList}" var="dList" varStatus="status">--%>
<%--                <c:if test="${dList.id}}}">--%>
<%--                    <tr>--%>
<%--                        <td class="h_35px" colspan="13">조회 목록이 없습니다.</td>--%>
<%--                    </tr>--%>
<%--                </c:if>--%>
<%--            </c:forEach>--%>
            <tr>
                <th>출입문 스케쥴 명</th>
                <td>
                    <input type="text" id="schNm" name="detail" maxlength="50" size="50" value="${doorScheduleDetail.door_sch_nm}" class="w_600px input_com" disabled>
                </td>
            </tr>
            <tr>
                <th>사용</th>
                <td>
                    <select id="schUseYn" name="detail" class="form-control w_600px" style="padding-left:10px;" disabled>
                        <option value="" name="selected">선택</option>
                        <option value="Y" <c:if test="${doorScheduleDetail.use_yn eq 'Y'}" >selected </c:if>>Y</option>
                        <option value="N" <c:if test="${doorScheduleDetail.use_yn eq 'N'}" >selected </c:if>>N</option>
                    </select>
                </td>
            </tr>
            <tr>
                <th>출입문 그룹</th>
                <td style="display: flex;">
<%--                    <textarea id="doorGroup" name="detail" rows="10" cols="33" class="w_600px" style="border-color: #ccc; border-radius: 2px;--%>
<%--                              font-size: 14px; line-height: 1.5; padding: 2px 10px;" disabled>${doorGroupList.size()}/${doorGroupList}</textarea>--%>
                    <textarea id="doorGroup" name="detail" rows="10" cols="33" class="w_600px" style="border-color: #ccc; border-radius: 2px;
                              font-size: 14px; line-height: 1.5; padding: 2px 10px;" disabled></textarea>
                    <div class="ml_10" style="position:relative;">
                        <button id="btnEdit" type="button" class="btn_middle color_basic" onclick="openPopup('doorGroupPickPopup')" style="position:absolute; bottom:0; display:none;">선택</button>
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
    <button class="btn_middle ml_5 color_basic" id="btnAddByDay" onclick="openPopup('addByDayPopup');">요일 별 스케쥴 등록</button>
</div>
<div class="right_btn mt_20" id="btnboxEdit" style="display:none;">
    <button class="btn_middle color_basic" onclick="fnSave();">확인</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnCancel();">취소</button>
</div>

<%--  요일 별 스케쥴 등록 modal  --%>
<div id="addByDayPopup" class="example_content" style="display: none;">
    <c:set var="days" value="${fn:split('월,화,수,목,금,토,일',',')}"/>
    <c:set var="days_eng" value="${fn:split('mon,tue,wed,thu,fri,sat,sun',',')}"/>
    <div class="popup_box box_w3" style="margin-top:0px; padding:20px;">
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
<%--                    <button type="button" class="comm_btn mr_20" onclick="fnDaySchDeleteOne()">개별삭제</button>--%>
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
                <button type="button" class="comm_btn mr_20" onclick="fnDaySchInit();">초기화</button>
                <button type="button" class="comm_btn mr_20" onclick="fnDaySchModify();">저장</button>
                <button type="button" class="comm_btn mr_20" onclick="fnDaySchDelete();">삭제</button>
                <button type="button" class="comm_btn" onclick="fnDaySchDetailMode();">취소</button>
            </div>
        </div>
        <div class="c_btnbox center mt_20" id="btnDaySchAdd">
            <div style="display: inline-block;">
                <button type="button" class="comm_btn mr_20" onclick="fnDaySchInit();">초기화</button>
                <button type="button" class="comm_btn mr_20" onclick="fnDaySchSave();">저장</button>
                <button type="button" class="comm_btn" onclick="closePopup('addByDayPopup');">닫기</button>
            </div>
        </div>
    </div>
</div>
<%--  end of 권한그룹 선택 modal  --%>


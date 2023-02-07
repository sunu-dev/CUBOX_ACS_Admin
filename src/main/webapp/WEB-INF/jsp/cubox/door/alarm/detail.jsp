<%--
  Created by IntelliJ IDEA.
  User: USER
  Date: 2022-09-21
  Time: 오전 11:23
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/jsp/cubox/common/checkPasswd.jsp" flush="false"/>
<jsp:include page="/WEB-INF/jsp/cubox/common/doorPickPopup.jsp" flush="false"/>
<%--<jsp:include page="/WEB-INF/jsp/cubox/common/doorListPopup.jsp" flush="false"/>--%>

<style>
    .title_box {
        margin-top: 10px;
        margin-bottom: 20px;
    }
    .box {
        border: 1px solid #ccc;
        /*width: 715px;*/
    }
    #tdAlarmDetail tr th {
        text-align: center;
    }
    thead {
        position: sticky;
        top: 0;
    }
    .color_disabled {
        background-color: #eee !important;
        opacity: 1;
    }
</style>

<script type="text/javascript">

    $(function() {
        $(".title_tx").html("출입문 알람 그룹 - 상세");

        modalPopup("doorEditPopup", "출입문 수정", 900, 600);

        // 출입문 알람그룹 명 유효성 체크
        $("#alNm").focusout(function() {

        });

        // 유형 - 기본시간
        $("#alUseYn").change(function() {
            chkAlType();
        });

    });

    // 유형:기본시간 --> 시간 고정
    function chkAlType() {
        if ($("#alUseYn").val() === "AUT001") { // 장시간 알람
            $("#alTime").attr("disabled", false);
        } else {
            $("#alTime").val("").attr("disabled", true);
        }
    }

    // 수정 확인
    function fnSave() {
        // 입력값 유효성 체크
        if (fnIsEmpty($("#alNm").val())) {
            alert("출입문 알람 그룹 명을 입력해주세요.");
            $("#alNm").focus(); return;
        } else if (fnIsEmpty($("#alUseYn").val())) {
            alert("사용여부를 선택해주세요.");
            $("#alUseYn").focus(); return;
        } else if (fnIsEmpty($("#alTime").val()) && $("#alUseYn").val() === "AUT001") { // 장시간알람일 때
            alert("시간을 입력해주세요.");
            $("#alTime").focus(); return;
        } else if (fnIsEmpty($("#alType").val())) {
            alert("유형을 선택해주세요.");
            $("#alType").focus();
            return;
        }


        if (confirm("출입문 알람그룹을 저장하시겠습니까?")) {
            fnUpdateAlarmGroupAjax();
        } else {
            return;
        }

    }

    // 수정 취소
    function fnCancel() {
        $(".title_tx").html("출입문 알람 그룹 - 상세");
        $("#btnEdit").css("display", "none");
        $("#btnboxDetail").css("display", "block");
        $("#btnboxEdit").css("display", "none");
        // 전체페이지 리로드 대신 html만 리로드
        $("#detailForm").load(location.href + ' #detailForm');
        $("[name=detail]").attr("disabled", true).addClass("color_disabled");
    }

    // 수정 버튼
    function fnEditMode() {
        if (confirm("해당 알람그룹을 수정하시겠습니까?")) {
            $(".title_tx").html("출입문 알람 그룹 - 수정");
            $("#btnEdit").css("display", "inline-block");
            $("#btnboxDetail").css("display", "none");
            $("#btnboxEdit").css("display", "block");
            $("[name=detail]").attr("disabled", false).removeClass("color_disabled");
        } else {
            return;
        }
    }

    // 삭제 버튼
    function fnDelete() {
        // 연결된 출입문 존재 시
        if ($("#doorIds").val() !== "") {
            alert("연결된 출입문을 모두 해제한 후 삭제하세요.");
            return;
        }

        if (!confirm("삭제하시겠습니까?")) {
            return;
        }

        fnDeleteAlarmGroupAjax();
    }

    // popup open (공통)
    function openPopup(popupNm) {
        $("#" + popupNm).PopupWindow("open");
        if (popupNm === "doorEditPopup") { // 출입문 수정 팝업
            fnGetDoorListAjax("AlarmGroup"); //출입문 목록
        }
    }

    // popup close (공통)
    function closePopup(popupNm) {
        setDoors("AlarmGroup");
        userCheck();
        $("#" + popupNm).PopupWindow("close");
    }


    /////////////////  출입문 알람그룹 저장 ajax - start  /////////////////////

    function fnUpdateAlarmGroupAjax() {
        let alNm = $("#alNm").val();
        let alUseYn = $("#alUseYn").val(); // 사용
        let alTime = $("#alTime").val();
        let alType = $("#alType").val();  // 알람유형
        let doorIds = $("#doorIds").val();
        let url = "<c:url value='/door/alarm/modify/${doorGroupDetail.id}'/>"

        $.ajax({
            type: "POST",
            url: url,
            data: {
                nm: alNm,
                alarm_use_type: alUseYn,
                time: alTime,
                door_alarm_type: alType,
                doorIds: doorIds
                // envYn: envYn,
                // deleteYn: deleteYn,
            },
            dataType: "json",
            success: function(result) {
                // console.log(result.resultCode);
                if (result.resultCode === "Y") {
                    alert("수정이 완료되었습니다.");
                    window.location.href = '/door/alarm/detail/${doorGroupDetail.id}';
                } else {
                    alert("수정에 실패하였습니다.");
                }
            }
        });
    }

    /////////////////  출입문 알람그룹 저장 ajax - end  /////////////////////


    /////////////////  출입문 알람그룹 삭제 ajax - start  /////////////////////

    function fnDeleteAlarmGroupAjax() {
        $.ajax({
            type: "post",
            url: "<c:url value='/door/alarm/delete/${doorGroupDetail.id}' />",
            dataType: 'json',
            success: function(result, status) {
                if (result.resultCode === "Y") {
                    alert("삭제가 완료되었습니다.");
                    location.href = "/door/alarm/list.do";
                } else {
                    alert("삭제 중 오류가 발생했습니다.");
                }
            }
        });
    }

    /////////////////  출입문 알람그룹 삭제 ajax - end  /////////////////////

</script>
<form id="detailForm" name="detailForm" method="post" enctype="multipart/form-data">
    <div class="tb_01_box">
        <table class="tb_write_02 tb_write_p1 box">
            <colgroup>
                <col style="width:10%">
                <col style="width:90%">
            </colgroup>
            <tbody id="tdAlarmDetail">
            <input type="hidden" id="alarmGroupId" value="${doorGroupDetail.id}">
            <input type="hidden" id="doorIds" value="${doorGroupDetail.door_ids}">
            <tr>
                <th>출입문 알람 그룹 명</th>
                <td>
                    <input type="text" id="alNm" name="detail" maxlength="35" value="${doorGroupDetail.nm}" class="input_com w_600px"
                           onkeyup="charCheck(this)" onkeydown="charCheck(this)" disabled>
                </td>
            </tr>
            <tr>
                <th>사용</th>
                <td>
                    <select id="alUseYn" name="detail" class="form-control input_com w_600px" style="padding-left:10px;" disabled>
                        <option value="">선택</option>
                        <c:forEach items="${alarmUseTypeList}" var="alarmUseType" varStatus="status">
                            <option value="${alarmUseType.cd}" <c:if test="${doorGroupDetail.alarm_use_typ eq alarmUseType.cd}">selected</c:if>>
                                    ${alarmUseType.cd_nm}
                            </option>
                        </c:forEach>
                    </select>
                </td>
            </tr>
            <tr>
                <th>시간</th>
                <td>
                    <input type="number" id="alTime" name="<c:if test='${doorGroupDetail.alarm_use_typ eq "AUT001"}'>detail</c:if>" min="1" max="9999" maxlength="4"
                           value="<c:if test='${doorGroupDetail.alarm_use_typ eq "AUT001"}'>${doorGroupDetail.time}</c:if>" class="input_com w_600px"
                           oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');this.value = this.value.slice(0,this.maxLength);" disabled>&ensp;초
                </td>
            </tr>
            <tr>
                <th>알람유형</th>
                <td>
                    <select id="alType" name="detail" class="form-control input_com w_600px" style="padding-left:10px;" disabled>
                        <option value="">선택</option>
                        <c:forEach items="${doorAlarmTypeList}" var="doorAlarmType" varStatus="status">
                            <option value="${doorAlarmType.cd}" <c:if test="${doorGroupDetail.door_alarm_typ eq doorAlarmType.cd}">selected</c:if>>
                                    ${doorAlarmType.cd_nm}
                            </option>
                        </c:forEach>
                    </select>
                </td>
            </tr>
            <tr>
                <th>출입문 수</th>
                <td>
                    <input type="text" id="alDoorCnt" name="alDoorCnt" maxlength="50" value="${doorGroupDetail.door_cnt}" class="input_com w_600px" disabled>
                </td>
            </tr>
            <tr>
                <th>출입문</th>
                <td style="display: flex;">
                    <textarea id="alDoorNms" name="alDoorNms" rows="10" cols="33" class="w_600px color_disabled" style="border-color: #ccc; border-radius: 2px; font-size: 14px; line-height: 1.5; padding: 2px 10px;" disabled><c:set var="nm" value="${fn:split(doorGroupDetail.door_nms,'/')}" /><c:forEach items="${nm}" var="dName" varStatus="varStatus">
${dName}</c:forEach></textarea>
                    <div class="ml_10" style="position: relative;">
                        <button id="btnEdit" type="button" class="btn_small color_basic" onclick="openPopup('doorEditPopup')" style="width:60px; position:absolute; bottom:0; display:none;">선택</button>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</form>

<div class="right_btn mt_20" id="btnboxDetail">
    <button class="btn_middle color_basic" onclick="location='/door/alarm/list.do'">목록</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnEditMode();">수정</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnDelete();">삭제</button>
</div>
<div class="right_btn mt_20" id="btnboxEdit" style="display: none;">
    <button class="btn_middle ml_5 color_basic" onclick="fnSave();">저장</button>
    <button class="btn_middle ml_5 color_basic" onclick="fnCancel();">취소</button>
</div>


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

    const defaultTime = 60; // 기본 시간 설정

    $(function() {
        $(".title_tx").html("출입문 알람 그룹 - 등록");

        // modalPopup("doorListPopup", "출입문 목록", 450, 550);
        modalPopup("doorEditPopup", "출입문 등록", 900, 600);

        chkAlType();

        // 출입문 알람그룹 명 유효성 체크
        $("#alNm").focusout(function() {
            // TODO : 출입문스케쥴명 유효성 체크 (ajax)
        });

        // 유형 - 기본시간
        $("#alType").change(function() {
            // console.log($(this).val());
            chkAlType();
        });

    });

    // 유형:기본시간 --> 시간 고정
    function chkAlType() {
        if ($("#alType").val() == "Y") {
            $("#alTime").val(defaultTime).attr("disabled", true);
        } else {
            $("#alTime").val("").attr("disabled", false);
        }
    }

    // 출입문 저장, 등록
    function fnSave() {
        // 입력값 유효성 체크
        if (fnIsEmpty($("#alNm").val())) {
            alert("출입문 알람 그룹 명을 입력해주세요.");
            $("#alNm").focus();
            return;
        } else if (fnIsEmpty($("#alType").val())) {
            alert("유형을 선택해주세요.");
            $("#alType").focus();
            return;
        } else if (fnIsEmpty($("#alTime").val())) {
            alert("시간을 입력해주세요.");
            $("#alTime").focus();
            return;
        } else if (fnIsEmpty($("#alUseYn").val())) {
            alert("사용여부를 선택해주세요.");
            $("#alUseYn").focus();
            return;
        }

        if (confirm("저장하시겠습니까?")) {
            fnSaveAlarmGroupAjax();
        } else {
            return;
        }
    }


    /////////////////  출입문 알람그룹 저장 ajax - start  /////////////////////

    function fnSaveAlarmGroupAjax() {
        let alNm = $("#alNm").val();
        let envYn = $("#alType").val();
        let alTime = $("#alTime").val();
        let deleteYn = $("#alUseYn").val();
        let doorIds = $("#doorIds").val();
        // TODO : 저장할 때 #alTime disabled 된 것 풀어줘야 함.

        $.ajax({
            type: "POST",
            url: "<c:url value='/door/alarm/save.do'/>",
            data: {
                nm: alNm,
                time: alTime,
                envYn: envYn,
                deleteYn: deleteYn,
                doorIds: doorIds
            },
            dataType: "json",
            success: function(result) {
                console.log(result);
                if (result.resultCode === "Y" && result.newDoorId !== "") {
                    alert("저장되었습니다.");
                    window.location.href = '/door/alarm/detail/' + result.newDoorId;
                } else {
                    alert("등록에 실패하였습니다.");
                }
            }
        });
    }

    /////////////////  출입문 알람그룹 저장 ajax - end  /////////////////////


    // popup open (공통)
    function openPopup(popupNm) {
        $("#" + popupNm).PopupWindow("open");
        if (popupNm === "doorEditPopup") {
            fnGetDoorListAjax("AlarmGroup");  // 출입문 등록
        }
    }

    // popup close (공통)
    function closePopup(popupNm) {
        setDoors("AlarmGroup");
        userCheck();
        $("#" + popupNm).PopupWindow("close");
    }

</script>
<form id="detailForm" name="detailForm" method="post" enctype="multipart/form-data">
    <div class="tb_01_box">
        <table class="tb_write_02 tb_write_p1 box">
            <colgroup>
                <col style="width:10%">
                <col style="width:90%">
            </colgroup>
            <tbody id="tdAlarmDetail">
            <input type="hidden" id="doorIds" value="">
            <tr>
                <th>출입문 알람 그룹 명</th>
                <td>
                    <input type="text" id="alNm" name="alNm" maxlength="35" value=""
                           class="input_com w_600px" onkeyup="charCheck(this)" onkeydown="charCheck(this)">
                </td>
            </tr>
            <tr>
                <th>유형</th>
                <td>
                    <select id="alType" name="alType" class="form-control input_com w_600px" style="padding-left:10px;">
                        <option value="" selected>선택</option>
                        <option value="Y">기본 시간</option>
                        <option value="N">지정시간</option>
                    </select>
                </td>
            </tr>
            <tr>
                <th>시간</th>
                <td>
                    <input type="number" id="alTime" name="detail" min="1" max="9999" maxlength="4" value="" class="input_com w_600px"
                           oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');this.value = this.value.slice(0,this.maxLength);" disabled>&ensp;초
                </td>
            </tr>
            <tr>
                <th>사용</th>
                <td>
                    <select id="alUseYn" name="alUseYn" class="form-control input_com w_600px" style="padding-left:10px;">
                        <option value="" selected>선택</option>
                        <option value="Y">사용</option>
                        <option value="N">미사용</option>
                    </select>
                </td>
            </tr>
            <tr>
                <th>출입문 수</th>
                <td>
                    <input type="number" id="alDoorCnt" name="alDoorCnt" maxlength="50" value="0" class="input_com w_600px" disabled>&ensp;
                </td>
            </tr>
            <tr>
                <th>출입문</th>
                <td style="display: flex;">
                    <textarea id="alDoorNms" name="alDoorNms" rows="10" cols="33" class="w_600px color_disabled" style="border-color: #ccc; border-radius: 2px; font-size: 14px; line-height: 1.5; padding: 2px 10px;" disabled></textarea>
                    <div class="ml_10" style="position: relative;">
                        <button type="button" class="btn_small color_basic" onclick="openPopup('doorEditPopup')" style="width:60px; position:absolute; bottom:0; display:block;">선택</button>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</form>

<div class="right_btn mt_20">
    <button class="btn_middle ml_5 color_basic" onclick="fnSave();">저장</button>
    <button class="btn_middle ml_5 color_basic" onclick="location='/door/alarm/list.do'">취소</button>
</div>


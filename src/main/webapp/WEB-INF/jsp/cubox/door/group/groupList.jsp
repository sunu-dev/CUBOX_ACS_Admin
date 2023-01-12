<%--
  Created by IntelliJ IDEA.
  User: USER
  Date: 2022-09-23
  Time: 오후 3:08
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/jsp/cubox/common/checkPasswd.jsp" flush="false"/>

<style>
    .title_box {
        margin-top: 10px;
        margin-bottom: 20px;
    }
    .tb_list tr {
        height: 55px;
    }
</style>

<script type="text/javascript">
    $(function() {
        fnGetDoorGroupListAjax();
        $(".title_tx").html("스케쥴 출입문 그룹 관리 - 목록");
        fnGetDoorGroupListAjax();


        $("#searchBtn").click(function() {
            //param1 : 검색어, param2 : 출입문 미등록 체크박스 value값 Y or N
            fnGetDoorGroupListAjax( $("#srchGroup").val()  );
        });

    });

    function fnDetail(self) {
        console.log(self); // 추후에 정보 넘김(id)
        location.href = "/door/group/detail.do";
    }



    function fnGetDoorGroupListAjax(param1) {
        console.log("fnGetDoorGroupListAjax");

        $.ajax({
            type: "GET",
            data: { keyword: param1},
            dataType: "json",
            url: "<c:url value='/door/group/list.do' />",
            success: function (result) {
                console.log("ajax success-[doorGroupList]" + result.doorGroupList);
            }
        });
    }

    function pageSearch(page){
        alert(page);


        $("#srchPage").val(page);
        fnGetDoorGroupListAjax

    }


</script>

<%--  검색 박스 --%>
<form id="frmGroup" name="frmGroup" method="post">
    <div class="search_box mb_20 mt_20" style="width: 40%;">
        <div class="search_in" style="width: 100%;">
            <div class="comm_search ml_10 mr_10" style="width: 90%;">
                <input type="text" class="input_com" id="srchGroup" name="srchGroup" value="" placeholder="출입문 그룹 명"/>
            </div>
            <div class="comm_search ml_40">
                <%--                <div class="search_btn2" onclick="pageSearch('1')"></div>--%>
                <div class="search_btn2" id="searchBtn"></div>
            </div>
        </div>
    </div>

    <div class="totalbox mb_20 mt_20" style="justify-content: end; width: 60%; height: 65px;">
        <div class="r_btnbox mb_10">
            <button type="button" class="btn_excel" data-toggle="modal" id="excelDownload" onclick="openExcelDownload();">엑셀다운로드</button>
        </div>
        <div class="r_btnbox ml_10 mb_10">
            <button type="button" class="btn_excel" data-toggle="modal" onclick="location='/door/group/addView.do'">신규등록</button>
        </div>
    </div>
    <%--  end of 검색 박스 --%>

    <div class="com_box">
        <%--  테이블  --%>
        <div class="tb_outbox">
            <table class="tb_list">
                <colgroup>
                    <col style="width:5%">
                    <col style="width:35%">
                    <col style="width:30%">
                    <col style="width:15%">
                    <col style="width:25%">
                </colgroup>
                <thead>
                <tr>
                    <th>No.</th>
                    <th>출입문 그룹 명</th>
                    <th>출입문 스케쥴 명</th>
                    <th>출입문 수</th>
                    <th>등록일자</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="i" begin="1" end="10" varStatus="status">
                    <tr>
                        <td><c:out value="${i}" /></td>
                        <td><a href="#none" onclick="fnDetail(this)">3동 현관</a></td>
                        <td>3동 평일</td>
                        <td>5</td>
                        <td>2022-09-01</td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
        <%--  end of 테이블  --%>
    </div>

    <jsp:include page="/WEB-INF/jsp/cubox/common/pagination.jsp" flush="false"/>
</form>

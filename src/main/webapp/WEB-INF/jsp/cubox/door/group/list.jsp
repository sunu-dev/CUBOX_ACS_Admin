<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<script type="text/javascript">
    $(function () {
        $(".title_tx").html("출입문 그룹 관리 - 목록");
    });

    //페이지 검색
    function pageSearch(page) {
        f = document.frmSearch;

        $("#srchPage").val(page);

        f.action = "/door/group/list.do";
        f.submit();
    }

    //출입문 그룹 추가
    function fnAddDoorGroup() {
        window.location.href = '/door/group/add.do';
    }

    // 엑셀 다운로드
    function fnExcelDownLoad() {
        window.location.href = '/door/group/excel/download.do';
    }
</script>

<form id="frmSearch" name="frmSearch" method="post">
    <input type="hidden" id="srchPage" name="srchPage" value="${pagination.curPage}"/>
    <!--검색박스 -->
    <div class="search_box mb_20">
        <div class="search_in">
            <div class="comm_search  mr_10">
                <input type="text" class="w_300px input_com" id="keyword" name="keyword" value="<c:out value="${data.keyword}"/>" placeholder="출입문 그룹명">
            </div>
            <div class="comm_search ml_40">
                <div class="search_btn2" onclick="pageSearch('1')"></div>
            </div>
        </div>
    </div>
    <!--//검색박스 -->
</form>

<div class="com_box">
    <div class="totalbox">
        <div class="txbox">
            <!-- 건수 -->
            <b class="fl mr_10">전체 : <c:out value="${pagination.totRecord}"/>건</b>
            <!-- // 건수 -->
        </div>
        <!--버튼 -->
        <div class="r_btnbox mb_10">
            <button type="button" class="btn_excel" id="excelDown" onclick="fnExcelDownLoad();">엑셀다운로드</button>
            <button type="button" class="btn_middle color_basic" id="addDoorGroup" onclick="fnAddDoorGroup()">신규등록
            </button>
        </div>
        <!--//버튼  -->
    </div>
    <!--테이블 시작 -->
    <div class="tb_outbox">
        <table class="tb_list">
            <colgroup>
                <col style="width:4%">
                <col style="width:34%">
                <col style="width:34%">
                <col style="width:8%">
                <col style="width:10%">
                <col style="width:10%">
            </colgroup>
            <thead>
            <tr>
                <th>No.</th>
                <th>출입문 그룹명</th>
                <th>출입문 스케쥴명</th>
                <th>출입문 수</th>
                <th>등록일자</th>
                <th>수정일자</th>
            </tr>
            </thead>
            <tbody id="doorGroupListBody">
            <c:if test="${doorGroupList == null || fn:length(doorGroupList) == 0}">
                <tr>
                    <td class="h_35px" colspan="13">조회 목록이 없습니다.</td>
                </tr>
            </c:if>
            <c:forEach items="${doorGroupList}" var="sList" varStatus="status">
                <tr>
                    <td>${(pagination.totRecord - (pagination.totRecord-status.index)+1)  + ( (pagination.curPage - 1)  *  pagination.recPerPage ) }</td>
                    <td><a href='/door/group/detail/<c:out value="${sList.id}"/>'><c:out value="${sList.nm}"/></a></td>
                    <td><c:out value="${sList.door_sch_nm}"/></td>
                    <td><c:out value="${sList.door_cnt}"/></td>
                    <td><c:out value="${sList.created_at}"/></td>
                    <td><c:out value="${sList.updated_at}"/></td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
    <!--------- //목록--------->
    <!-- 페이징 -->
    <jsp:include page="/WEB-INF/jsp/cubox/common/pagination.jsp" flush="false"/>
    <!-- /페이징 -->
</div>

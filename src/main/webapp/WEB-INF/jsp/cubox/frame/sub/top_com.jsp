<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="aero.cubox.core.vo.LoginVO" %>
<%@ page import="aero.cubox.util.AuthorManager" %>
<%-- <%@ page import="vo.menu.aero.cubox.MenuDetailVO" %> --%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="aero.cubox.core.vo.MenuVO" %>
<%
	Date nowTime = new Date();
	SimpleDateFormat sf = new SimpleDateFormat("yyyy년 MM월 dd일");
%>
<%
	AuthorManager authorManager = AuthorManager.getInstance();
	LoginVO loginVO = (LoginVO)session.getAttribute("loginVO");
	String authorId = "";
	if(loginVO!= null) {
		authorId = loginVO.getRole_id ();
	}

	//대메뉴 조회
	List<MenuVO> menuList = null;
	if(authorManager != null) {

		//menuClList = authorManager.getMenuCl (authorId);
		menuList = authorManager.getMenuList (authorId);
	}
	pageContext.setAttribute("menuList", menuList);



	//String strUriPath = (String) session.getAttribute("uriPath");
%>
<body>
	<!--상단영역 공통  -->
	<header class="main">
		<div class="logo" style="width: 250px;">
			<a href="/main.do">
				<img id="topLeftLogo" src="/img/logo/logo_<spring:eval expression="@property['Globals.site.main.id']" />.png" alt="" style="max-width: 170px; <c:if test="${sessionScope.loginVO.role_id ne '00008'}">display: none;</c:if>"/>
			</a>
		</div>
		<div class="title_box">
			<div class="title_time" style="margin-top: 24px;"><em style="font-size: 16px;color: #000;font-weight: 700; font-family: 'Noto Sans KR', sans-serif; margin-right: 5px; line-height: 35px;"><%= sf.format(nowTime) %></em> Recent Updates </div>
		</div>
		<div class="search_topbox" style="display: none;">
			<div class="input_box">
				<div class="line"></div>
				<input type="text" class="input_stin" placeholder="search">
				<button type="button" class="search_btn"></button>
			</div>
		</div>
		<div class="login_in_iconbox">
			<div class="member">
				<div class="img">
					<img src="/img/icon_member.png" alt="" />
				</div>
				<p>
					<!--[<c:out value="${sessionScope.loginVO.user_nm}"/>] 부서, 소속이름 테이블 변경 필요.--> <c:out value="${sessionScope.loginVO.user_nm}"/>
				</p>
			</div>
			<button type="button" class="pw" onclick="fnPassChange();">비밀번호 변경</button>
			<button type="button" class="logout" onclick="fnLogout();">로그아웃</button>
		</div>
	</header>
	<!--//상단영역 공통  -->
	<c:if test="${sessionScope.loginVO.role_id ne '00008'}"><input type="checkbox" id="menu_state" checked></c:if>
	<nav>
		<c:if test="${sessionScope.loginVO.role_id ne '00008'}"><label for="menu_state"><i class="fa"></i></label></c:if>
		<div class="left_title" style="background-color: #FFFFFF">
			<a href="/main.do">
				<img src="/img/logo/logo_<spring:eval expression="@property['Globals.site.main.id']" />_w.png" alt="logo" />
			</a>
		</div>
		<!-- 메뉴 자동 -->
		<ul class="nav" id="demo1">
		<c:forEach var="result" items="${menuList}" varStatus="status">
			<li>
				<a href="" style="background: url('/img/${result.icon_img}');">${result.menu_nm}</a>
				<c:if test="${result.list != null && fn:length(result.list) > 0 }">
					<ul class="menu2">
						<c:forEach var="menuList" items="${result.list}" varStatus="dStatus">
							<li class="li-a"><a href="${menuList.menu_url}">${menuList.menu_nm}</a></li>
						</c:forEach>
					</ul>
				</c:if>
			</li>
		</c:forEach>
		</ul>
		<div style="position: absolute; left: 10; bottom: 0; "></div>
	</nav>

	<script type="text/javascript">
		function fnLogout () {
			location.href = "/logout.do";
		}
		function fnPassChange () {
			location.href = "/admin/pwChange.do";
		}
		$(function() {
			$(".nav > li").removeClass("open");
			$(".menu2").hide();

			$(".fa").click(function(){
				if($("#topLeftLogo").css("display") == "none") {
					$("#topLeftLogo").show();
				} else {
					$("#topLeftLogo").hide();
				}
			});

			var currentURI = "${sessionScope.uriPath}";
			$('.li-a > a').each(function(i) {
				var strHref = $('.li-a > a').eq(i).attr('href');
				if (strHref != null && $.trim(strHref) != "" && currentURI.indexOf(strHref) > -1) {
					$('.li-a > a').eq(i).parent().parent().parent().addClass('open');
					$('.li-a > a').eq(i).parent().parent().show();
				}
			});
		});
	</script>

</body>
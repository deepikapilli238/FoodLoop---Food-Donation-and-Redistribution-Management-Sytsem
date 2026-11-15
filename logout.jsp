<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    // Prevent the logout response from being stored in the browser cache.
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Destroy the current session, if one exists.
    if (session != null) {
        session.invalidate();
    }

    // Send the user back to login.
    response.sendRedirect("login.jsp?logout=1");
    return;
%>
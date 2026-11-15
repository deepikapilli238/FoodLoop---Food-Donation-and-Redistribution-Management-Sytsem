
package com.foodloop.controller;

import com.foodloop.dao.UserDAO;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/admin/delete-user")
public class AdminDeleteUserServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("userId") == null
                || !"ADMIN".equalsIgnoreCase(
                        String.valueOf(session.getAttribute("userRole")))) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Admin privileges are required."
            );
            return;
        }

        String userIdValue = request.getParameter("userId");

        if (userIdValue == null || userIdValue.trim().isEmpty()) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-users.jsp?error=invalid"
            );
            return;
        }

        int userId;

        try {
            userId = Integer.parseInt(userIdValue.trim());

            if (userId <= 0) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/manage-users.jsp?error=invalid"
                );
                return;
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-users.jsp?error=invalid"
            );
            return;
        }

        try {
            boolean deactivated = userDAO.deleteUserByAdmin(userId);

            if (deactivated) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/manage-users.jsp?deleted=1"
                );
            } else {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/manage-users.jsp?error=notfound"
                );
            }

        } catch (SQLException e) {
            getServletContext().log(
                    "Failed to deactivate user ID: " + userId, e
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-users.jsp?error=deletefailed"
            );
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Allow", "POST");

        response.sendError(
                HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                "Use POST to deactivate a user."
        );
    }
}

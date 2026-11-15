package com.foodloop.controller;

import com.foodloop.model.User;
import com.foodloop.service.UserService;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            User user = userService.login(email, password);

            if (user == null) {
                response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp?error=invalid_credentials"
                );
                return;
            }

            // Prevent session fixation.
            HttpSession oldSession = request.getSession(false);

            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("userName", user.getFullName());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userRole", user.getRole());

            session.setMaxInactiveInterval(30 * 60);

            String contextPath = request.getContextPath();

            switch (user.getRole().toUpperCase()) {

                case "ADMIN":
                    response.sendRedirect(
                        contextPath + "/admin/dashboard.jsp"
                    );
                    break;

                case "DONOR":
                    response.sendRedirect(
                        contextPath + "/donor/donor-dashboard.jsp"
                    );
                    break;

                case "NGO":
                    response.sendRedirect(
                        contextPath + "/ngo/ngo-dashboard.jsp"
                    );
                    break;

                default:
                    session.invalidate();

                    response.sendRedirect(
                        contextPath + "/login.jsp?error=invalid_role"
                    );
            }

        } catch (SQLException e) {

            log("Database error during login.", e);

            response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=database_error"
            );
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
            request.getContextPath() + "/login.jsp"
        );
    }
}
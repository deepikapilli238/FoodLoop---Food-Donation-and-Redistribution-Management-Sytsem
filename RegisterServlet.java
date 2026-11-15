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

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

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

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");

        try {
            User user = new User(
                    fullName,
                    email,
                    password,
                    phone,
                    role
            );

            boolean registered = userService.register(user);

            if (registered) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/login.jsp?registered=success"
                );
            } else {
                response.sendRedirect(
                        request.getContextPath()
                        + "/register.jsp?error=registration_failed"
                );
            }

        } catch (IllegalArgumentException e) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=invalid_input"
            );

        } catch (SQLException e) {

            log("Database error during registration.", e);

            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=database_error"
            );
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath() + "/register.jsp"
        );
    }
}
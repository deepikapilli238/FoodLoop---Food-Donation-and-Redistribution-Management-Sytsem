package com.foodloop.controller;

import com.foodloop.dao.FoodRequestDAO;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/donor/request-action")
public class DonationRequestActionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final FoodRequestDAO foodRequestDAO = new FoodRequestDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        // Check login session
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        // Only donors can accept or reject requests
        String role = String.valueOf(session.getAttribute("userRole"));

        if (!"DONOR".equalsIgnoreCase(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only donors can process donation requests."
            );
            return;
        }

        int donorId;
        int requestId;

        try {
            donorId = Integer.parseInt(
                    String.valueOf(session.getAttribute("userId"))
            );

            requestId = Integer.parseInt(
                    request.getParameter("requestId")
            );

            if (donorId <= 0 || requestId <= 0) {
                throw new NumberFormatException("Invalid ID");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(
                    contextPath + "/donor/donation-requests?result=invalid"
            );
            return;
        }

        // Determine the requested action
        String action = request.getParameter("action");
        String newStatus;

        if ("accept".equalsIgnoreCase(action)) {
            newStatus = "ACCEPTED";
        } else if ("reject".equalsIgnoreCase(action)) {
            newStatus = "REJECTED";
        } else {
            response.sendRedirect(
                    contextPath + "/donor/donation-requests?result=invalid"
            );
            return;
        }

        // Update the request in Oracle
        try {
            boolean updated = foodRequestDAO.updateRequestStatus(
                    requestId,
                    donorId,
                    newStatus
            );

            if (updated) {
                String result = "ACCEPTED".equals(newStatus)
                        ? "accepted"
                        : "rejected";

                response.sendRedirect(
                        contextPath + "/donor/donation-requests?result=" + result
                );
            } else {
                response.sendRedirect(
                        contextPath + "/donor/donation-requests?result=unchanged"
                );
            }

        } catch (SQLException e) {
            getServletContext().log(
                    "Unable to update donation request ID " + requestId,
                    e
            );

            throw new ServletException(
                    "Unable to update the donation request. Check the server logs.",
                    e
            );
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendError(
                HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                "Use POST to process a donation request."
        );
    }
}
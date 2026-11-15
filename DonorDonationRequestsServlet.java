
package com.foodloop.controller;

import com.foodloop.dao.FoodRequestDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/donor/donation-requests")
public class DonorDonationRequestsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final FoodRequestDAO foodRequestDAO = new FoodRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Ensure the donor is logged in.
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Only donors can access this page.
        Object roleObject = session.getAttribute("userRole");

        if (roleObject == null
                || !"DONOR".equalsIgnoreCase(String.valueOf(roleObject))) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only donors can view donation requests.");
            return;
        }

        // Read the logged-in donor ID from the session.
        int donorId;

        try {
            Object userId = session.getAttribute("userId");

            if (userId instanceof Number) {
                donorId = ((Number) userId).intValue();
            } else {
                donorId = Integer.parseInt(String.valueOf(userId));
            }

            if (donorId <= 0) {
                throw new NumberFormatException("Invalid donor ID");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Retrieve only requests for this donor's donations.
        try {
            List<Map<String, Object>> donationRequests =
                    foodRequestDAO.getRequestsForDonor(donorId);

            request.setAttribute("donationRequests", donationRequests);

            request.getRequestDispatcher(
                    "/donor/donation-requests.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            getServletContext().log(
                    "Failed to load donation requests for donor ID: "
                            + donorId,
                    e);

            throw new ServletException(
                    "Unable to load donation requests from the database.",
                    e);
        }
    }
}
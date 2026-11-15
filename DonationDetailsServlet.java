
package com.foodloop.controller;

import com.foodloop.dao.DonationDAO;
import com.foodloop.model.Donation;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/donor/donation-details")
public class DonationDetailsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DonationDAO donationDAO = new DonationDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        // Verify the donor session.
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        String role = String.valueOf(session.getAttribute("userRole"));

        if (!"DONOR".equalsIgnoreCase(role)) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Only donors can view their donation details."
            );
            return;
        }

        // Read the selected donation ID.
        String donationIdValue = request.getParameter("donationId");

        if (donationIdValue == null || donationIdValue.trim().isEmpty()) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Donation ID is required."
            );
            return;
        }

        int donationId;
        int donorId;

        try {
            donationId = Integer.parseInt(donationIdValue.trim());

            donorId = Integer.parseInt(
                String.valueOf(session.getAttribute("userId"))
            );

            if (donationId <= 0 || donorId <= 0) {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid donation ID."
                );
                return;
            }

        } catch (NumberFormatException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid donation ID."
            );
            return;
        }

        try {
            // Load a donation belonging to this logged-in donor.
            Donation donation =
                donationDAO.getDonationByIdForDonor(donationId, donorId);

            if (donation == null) {
                response.sendRedirect(
                    contextPath + "/donor/my-donations?message=notfound"
                );
                return;
            }

            request.setAttribute("donation", donation);

            // Open the existing donation details JSP.
            request.getRequestDispatcher(
                "/donor/donation-details.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to retrieve donation details.", e
            );
        }
    }
}
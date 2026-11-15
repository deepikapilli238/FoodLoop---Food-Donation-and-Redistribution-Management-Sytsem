
package com.foodloop.controller;

import com.foodloop.dao.DonationDAO;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/admin/delete-donation")
public class AdminDeleteDonationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DonationDAO donationDAO = new DonationDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // Only logged-in ADMIN users can delete donations.
        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("userRole") == null
                || !"ADMIN".equalsIgnoreCase(
                        String.valueOf(session.getAttribute("userRole")))) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Access denied. Admin privileges are required."
            );
            return;
        }

        // Accept POST requests only.
        response.setHeader("Cache-Control", "no-store");

        String donationIdValue = request.getParameter("donationId");

        if (donationIdValue == null || donationIdValue.trim().isEmpty()) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Donation ID is required."
            );
            return;
        }

        final int donationId;

        try {
            donationId = Integer.parseInt(donationIdValue.trim());

            if (donationId <= 0) {
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
            boolean deleted = donationDAO.deleteDonationByAdmin(donationId);

            if (deleted) {
                // Redirect back to the admin donations page.
                response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-donations.jsp?deleted=1"
                );
            } else {
                response.sendRedirect(
                    request.getContextPath()
                    + "/admin/manage-donations.jsp?error=notfound"
                );
            }

        } catch (SQLException e) {
            // Log the actual error on the server; don't expose DB details.
            getServletContext().log(
                "Failed to delete donation ID " + donationId,
                e
            );

            response.sendRedirect(
                request.getContextPath()
                + "/admin/manage-donations.jsp?error=deletefailed"
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
            "Use POST to delete a donation."
        );
    }
}

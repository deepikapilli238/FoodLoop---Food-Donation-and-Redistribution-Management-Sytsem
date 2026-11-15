
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

@WebServlet("/donor/edit-donation")
public class EditDonationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DonationDAO donationDAO = new DonationDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = String.valueOf(session.getAttribute("userRole"));

        if (!"DONOR".equalsIgnoreCase(role)) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Only donors can edit donations."
            );
            return;
        }

        int donationId;
        int donorId;

        try {
            donationId = Integer.parseInt(
                request.getParameter("donationId")
            );

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

        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "A valid donation ID is required."
            );
            return;
        }

        try {
            Donation donation =
                donationDAO.getDonationByIdForDonor(donationId, donorId);

            if (donation == null) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Donation not found or you do not have permission to edit it."
                );
                return;
            }

            request.setAttribute("donation", donation);

            request.getRequestDispatcher(
                "/donor/edit-donation.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to load donation details.", e
            );
        }
    }
}

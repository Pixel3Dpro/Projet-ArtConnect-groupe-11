package com.project.artconnect.service.impl;

import com.project.artconnect.dao.WorkshopDao;
import com.project.artconnect.model.Booking;
import com.project.artconnect.model.CommunityMember;
import com.project.artconnect.model.Workshop;
import com.project.artconnect.service.WorkshopService;
import com.project.artconnect.util.ConnectionManager;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public class JdbcWorkshopService implements WorkshopService {

    private final WorkshopDao workshopDao;

    public JdbcWorkshopService(WorkshopDao workshopDao) {
        this.workshopDao = workshopDao;
    }

    @Override
    public List<Workshop> getAllWorkshops() {
        return workshopDao.findAll();
    }

    @Override
    public Optional<Workshop> getWorkshopByTitle(String title) {
        return workshopDao.findAll().stream()
            .filter(w -> w.getTitle().equals(title))
            .findFirst();
    }

    @Override
    public void bookWorkshop(Workshop workshop, CommunityMember member) {
        String sqlWorkshop = "SELECT id_workshop FROM WORKSHOP WHERE title=?";
        String sqlMember   = "SELECT id_member FROM COMMUNITY_MEMBER WHERE email=?";
        String sqlInsert   = "INSERT INTO BOOKING (id_workshop, id_member, bookingDate, paymentStatus) VALUES (?,?,?,?)";
        try (Connection conn = ConnectionManager.getConnection()) {
            conn.setAutoCommit(false);
            int workshopId, memberId;
            try (PreparedStatement ps = conn.prepareStatement(sqlWorkshop)) {
                ps.setString(1, workshop.getTitle());
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) { conn.rollback(); return; }
                workshopId = rs.getInt("id_workshop");
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlMember)) {
                ps.setString(1, member.getEmail());
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) { conn.rollback(); return; }
                memberId = rs.getInt("id_member");
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlInsert)) {
                ps.setInt(1, workshopId);
                ps.setInt(2, memberId);
                ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
                ps.setString(4, "PENDING");
                ps.executeUpdate();
            }
            conn.commit();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Booking> getBookingsByMember(CommunityMember member) {
        return member.getBookings();
    }
}

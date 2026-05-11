package com.project.artconnect.persistence;

import com.project.artconnect.dao.WorkshopDao;
import com.project.artconnect.model.Artist;
import com.project.artconnect.model.Workshop;
import com.project.artconnect.util.ConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcWorkshopDao implements WorkshopDao {

    private Workshop mapRow(ResultSet rs) throws SQLException {
        Workshop w = new Workshop();
        w.setTitle(rs.getString("title"));
        w.setDate(rs.getTimestamp("date").toLocalDateTime());
        w.setDurationMinutes(rs.getInt("durationMinutes"));
        w.setMaxParticipants(rs.getInt("maxParticipants"));
        w.setPrice(rs.getDouble("price"));
        w.setLocation(rs.getString("location"));
        w.setDescription(rs.getString("description"));
        w.setLevel(rs.getString("level"));
        Artist instructor = new Artist();
        instructor.setName(rs.getString("artist_name"));
        w.setInstructor(instructor);
        return w;
    }

    @Override
    public List<Workshop> findAll() {
        List<Workshop> list = new ArrayList<>();
        String sql = "SELECT w.*, ar.name AS artist_name FROM WORKSHOP w JOIN ARTIST ar ON w.id_artist = ar.id_artist";
        try (Connection conn = ConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Optional<Workshop> findById(Long id) {
        String sql = "SELECT w.*, ar.name AS artist_name FROM WORKSHOP w JOIN ARTIST ar ON w.id_artist = ar.id_artist WHERE w.id_workshop=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return Optional.empty();
    }
}

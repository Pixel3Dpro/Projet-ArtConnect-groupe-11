package com.project.artconnect.persistence;

import com.project.artconnect.dao.GalleryDao;
import com.project.artconnect.model.Gallery;
import com.project.artconnect.util.ConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcGalleryDao implements GalleryDao {

    private Gallery mapRow(ResultSet rs) throws SQLException {
        Gallery g = new Gallery();
        g.setName(rs.getString("name"));
        g.setAddress(rs.getString("address"));
        g.setOwnerName(rs.getString("ownerName"));
        g.setOpeningHours(rs.getString("openingHours"));
        g.setContactPhone(rs.getString("contactPhone"));
        g.setRating(rs.getDouble("rating"));
        g.setWebsite(rs.getString("website"));
        return g;
    }

    @Override
    public List<Gallery> findAll() {
        List<Gallery> list = new ArrayList<>();
        String sql = "SELECT * FROM GALLERY";
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
    public Optional<Gallery> findById(Long id) {
        String sql = "SELECT * FROM GALLERY WHERE id_gallery=?";
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

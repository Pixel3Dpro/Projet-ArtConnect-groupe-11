package com.project.artconnect.persistence;

import com.project.artconnect.dao.ExhibitionDao;
import com.project.artconnect.model.Exhibition;
import com.project.artconnect.model.Gallery;
import com.project.artconnect.util.ConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcExhibitionDao implements ExhibitionDao {

    private Exhibition mapRow(ResultSet rs) throws SQLException {
        Exhibition e = new Exhibition();
        e.setTitle(rs.getString("title"));
        e.setStartDate(rs.getDate("startDate").toLocalDate());
        Date endDate = rs.getDate("endDate");
        if (endDate != null) e.setEndDate(endDate.toLocalDate());
        e.setDescription(rs.getString("description"));
        e.setCuratorName(rs.getString("curatorName"));
        e.setTheme(rs.getString("theme"));
        Gallery g = new Gallery();
        g.setName(rs.getString("gallery_name"));
        e.setGallery(g);
        return e;
    }

    @Override
    public List<Exhibition> findAll() {
        List<Exhibition> list = new ArrayList<>();
        String sql = "SELECT ex.*, ga.name AS gallery_name " +
                     "FROM EXHIBITION ex " +
                     "JOIN GALLERY ga ON ex.id_gallery = ga.id_gallery";
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
    public Optional<Exhibition> findById(Long id) {
        String sql = "SELECT ex.*, ga.name AS gallery_name " +
                     "FROM EXHIBITION ex " +
                     "JOIN GALLERY ga ON ex.id_gallery = ga.id_gallery " +
                     "WHERE ex.id_exhibition = ?";
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

    @Override
    public void save(Exhibition ex) {
        String sqlGallery = "SELECT id_gallery FROM GALLERY WHERE name=?";
        String sql = "INSERT INTO EXHIBITION (title, startDate, endDate, description, curatorName, theme, id_gallery) VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = ConnectionManager.getConnection()) {
            int galleryId;
            try (PreparedStatement ps = conn.prepareStatement(sqlGallery)) {
                ps.setString(1, ex.getGallery().getName());
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) return;
                galleryId = rs.getInt("id_gallery");
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, ex.getTitle());
                ps.setDate(2, Date.valueOf(ex.getStartDate()));
                ps.setDate(3, ex.getEndDate() != null ? Date.valueOf(ex.getEndDate()) : null);
                ps.setString(4, ex.getDescription());
                ps.setString(5, ex.getCuratorName());
                ps.setString(6, ex.getTheme());
                ps.setInt(7, galleryId);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void update(Exhibition ex) {
        String sql = "UPDATE EXHIBITION SET startDate=?, endDate=?, description=?, curatorName=?, theme=? WHERE title=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(ex.getStartDate()));
            ps.setDate(2, ex.getEndDate() != null ? Date.valueOf(ex.getEndDate()) : null);
            ps.setString(3, ex.getDescription());
            ps.setString(4, ex.getCuratorName());
            ps.setString(5, ex.getTheme());
            ps.setString(6, ex.getTitle());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void delete(String title) {
        String sql = "DELETE FROM EXHIBITION WHERE title=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

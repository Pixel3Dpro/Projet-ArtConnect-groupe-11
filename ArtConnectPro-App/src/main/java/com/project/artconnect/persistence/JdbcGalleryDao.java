package com.project.artconnect.persistence;

import com.project.artconnect.dao.GalleryDao;
import com.project.artconnect.model.Exhibition;
import com.project.artconnect.model.Gallery;
import com.project.artconnect.util.ConnectionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class JdbcGalleryDao implements GalleryDao {

    @Override
    public List<Gallery> findAll() {
        List<Gallery> list = new ArrayList<>();
        String sql = "SELECT * FROM GALLERY";
        try (Connection conn = ConnectionManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Gallery g = mapRow(rs);
                g.setExhibitions(findExhibitionsByGallery(conn, rs.getInt("id_gallery")));
                list.add(g);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<Exhibition> findExhibitionsByGallery(Connection conn, int galleryId) throws SQLException {
        List<Exhibition> exList = new ArrayList<>();
        String sql = "SELECT * FROM EXHIBITION WHERE id_gallery=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, galleryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Exhibition e = new Exhibition();
                    e.setTitle(rs.getString("title"));
                    e.setStartDate(rs.getDate("startDate").toLocalDate());
                    Date endDate = rs.getDate("endDate");
                    if (endDate != null) e.setEndDate(endDate.toLocalDate());
                    e.setDescription(rs.getString("description"));
                    e.setCuratorName(rs.getString("curatorName"));
                    e.setTheme(rs.getString("theme"));
                    exList.add(e);
                }
            }
        }
        return exList;
    }

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
    public Optional<Gallery> findById(Long id) {
        String sql = "SELECT * FROM GALLERY WHERE id_gallery=?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Gallery g = mapRow(rs);
                    g.setExhibitions(findExhibitionsByGallery(conn, id.intValue()));
                    return Optional.of(g);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return Optional.empty();
    }
}

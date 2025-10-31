package org.example.ptcmssbackend.service;

import org.example.ptcmssbackend.dto.request.CreateBranchRequest;
import org.example.ptcmssbackend.dto.request.UpdateBranchRequest;
import org.example.ptcmssbackend.dto.response.BranchResponse;
import org.example.ptcmssbackend.dto.response.common.PageResponse;
import org.example.ptcmssbackend.entity.Branches;
import org.springframework.data.domain.Page;

import java.util.List;

public interface BranchService {
    BranchResponse createBranch(CreateBranchRequest request);
    Integer updateBranch(Integer id, UpdateBranchRequest request);
    PageResponse<?> getAllBranches(String keyword, int pageNo, int pageSize, String sortBy);
    BranchResponse getBranchById(Integer id);
    Integer deleteBranch(Integer id);
}

import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { FiPlus, FiEdit, FiTrash2 } from "react-icons/fi";

import {
  PageHeader,
  SearchFilterBar,
  ListView,
  DeleteConfirmButton,
  StatusBadge,
} from "../../../../components/master/Controls/SharedUIHelpers";

import { feesService } from "../../../../services/productManagementService";

/* ================= HELPER MAPS ================= */
const FREQUENCY_LABELS = {
  ONE_TIME: "One-time",
  MONTHLY: "Monthly",
  ANNUALLY: "Annually",
};

const BASIS_LABELS = {
  FIXED: "Fixed",
  PERCENTAGE: "Percentage",
  SLAB: "Slab-based",
};

const RECOVERY_STAGE_LABELS = {
  DISBURSEMENT: "Disbursement",
  ONGOING: "Ongoing",
  CLOSURE: "Closure",
};

const RECOVERY_MODE_LABELS = {
  DIRECT_DEBIT: "Direct Debit",
  AUTO_DEBIT: "Auto-debit",
  CASH: "Cash",
};

const FeeList = () => {
  const navigate = useNavigate();

  const [fees, setFees] = useState([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [deleteId, setDeleteId] = useState(null);

  /* ================= LOAD FEES ================= */
  useEffect(() => {
    (async () => {
      try {
        const data = await feesService.getFees();
        setFees(Array.isArray(data) ? data : (data?.results || []));
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  /* ================= DELETE FEE ================= */
  const handleDelete = async (id) => {
    try {
      await feesService.deleteFee(id);
      setFees((prev) => prev.filter((f) => f.id !== id));
      setDeleteId(null);
    } catch (err) {
      console.error(err);
    }
  };

  /* ================= FILTER ================= */
  const filteredFees = fees.filter(
    (f) =>
      f.name?.toLowerCase().includes(search.toLowerCase()) ||
      f.fee_type?.toLowerCase().includes(search.toLowerCase())
  );

  /* ================= LIST CONFIG ================= */
  const columns = [
    { key: "name", label: "Fee Name" },
    {
      key: "fees_frequency",
      label: "Frequency",
      render: (v, row) => FREQUENCY_LABELS[v] || v,
    },
    {
      key: "basis_of_fees",
      label: "Basis",
      render: (v, row) => BASIS_LABELS[v] || v,
    },
    {
      key: "fees_recovery_stage",
      label: "Recovery Stage",
      render: (v, row) => RECOVERY_STAGE_LABELS[v] || v,
    },
    {
      key: "fees_recovery_mode",
      label: "Mode",
      render: (v, row) => RECOVERY_MODE_LABELS[v] || v,
    },
    { key: "fees_rate", label: "Rate" },

  ];

  const actions = [
    {
      icon: <FiEdit />,
      color: "blue",
      onClick: (row) => navigate(`/fees/${row.id}/edit`),
    },
    {
      icon: <FiTrash2 />,
      color: "red",
      onClick: (row) => setDeleteId(row.id),
    },
  ];

  return (
    <>
      {/* ================= HEADER ================= */}
      <PageHeader
        title="Fees Management"
        subtitle="Manage fee definitions and recovery rules"
        actionLabel="Add Fee"
        actionIcon={<FiPlus />}
        onAction={() => navigate("/fees/add")}
      />

      {/* ================= SEARCH ================= */}
      <SearchFilterBar
        search={search}
        onSearchChange={setSearch}
        placeholder="Search fee name..."
      />

      {/* ================= LIST ================= */}
      {loading ? (
        <p className="text-gray-500 text-sm">Loading fees...</p>
      ) : filteredFees.length === 0 ? (
        <p className="text-gray-500 text-sm">No fees found.</p>
      ) : (
        <ListView
          data={filteredFees}
          columns={columns}
          actions={actions}
          rowKey="id"
        />
      )}

      {/* ================= DELETE CONFIRM ================= */}
      {deleteId && (
        <DeleteConfirmButton
          title="Delete Fee"
          message="Are you sure you want to delete this fee?"
          onCancel={() => setDeleteId(null)}
          onConfirm={() => handleDelete(deleteId)}
        />
      )}
    </>
  );
};

export default FeeList;

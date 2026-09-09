from fastapi import APIRouter
from ..models.schemas import IntegrityAuditTrailResponse, BlockchainVerifyResponse
from ..blockchain.integrity_ledger import integrity_ledger

router = APIRouter(tags=["Blockchain & Data Integrity"])

@router.get("/blockchain/verify/{record_id}", response_model=BlockchainVerifyResponse)
@router.get("/integrity/verify/{record_id}", response_model=BlockchainVerifyResponse)
def verify_record_integrity(record_id: str):
    """
    Verifies cryptographic SHA-256 hash validity of an agronomic record or transaction.
    Returns integrity verification status (INTEGRITY VERIFIED | INTEGRITY CHECK FAILED).
    """
    res = integrity_ledger.verify_record(record_id)
    return BlockchainVerifyResponse(**res)

@router.get("/integrity/audit-trail", response_model=IntegrityAuditTrailResponse)
@router.get("/blockchain/audit-trail", response_model=IntegrityAuditTrailResponse)
def get_blockchain_audit_trail():
    """Returns cryptographic SHA-256 chained transaction blocks for decision auditing."""
    trail = integrity_ledger.get_audit_trail()
    return IntegrityAuditTrailResponse(**trail)

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract vote {

    event ChairmanResult(string chairman_elected);
    event ViChairmanResult(string vicechairman_elected);

    struct Voter {
        bool first_voted;
        bool second_voted;
    }
    struct Candidate {
        string name;
        uint firstVoteCount;
        uint secondVoteCount;
        bool elected;
    }
    address public owner;
    Candidate[] public candidates;

    mapping(address => Voter) public voters;

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    //후보자 등록 함수
    constructor(string memory a, string memory b, string memory c, string memory d, string memory e) {
        owner = msg.sender;

        string[5] memory candidateName;
        candidateName[0]=a;
        candidateName[1]=b;
        candidateName[2]=c;
        candidateName[3]=d;
        candidateName[4]=e;

        for(uint i=0;i<5;i++){
            Candidate memory A;
            A.name=candidateName[i];
            A.firstVoteCount=0;
            A.secondVoteCount=0;
            A.elected=false;
            candidates.push(A);
        }
    }

    //1차 투표 함수
    function firstVote(string memory to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.first_voted, "Already voted.");
        bool flag=false;
        for(uint i=0;i<candidates.length;i++){
            if(keccak256(bytes(to))==keccak256(bytes(candidates[i].name))){
                flag=true;
                candidates[i].firstVoteCount+=1;
            }
        }
        require(flag, "Not a Candidate");
        sender.first_voted=true;
    }

    //1차 개표 함수
    function firstCountVote() public isOwner{
        uint max_val=0;
        uint elected_idx=0;
        for(uint i=0;i<candidates.length;i++){
            if(max_val<candidates[i].firstVoteCount){
                max_val=candidates[i].firstVoteCount;
                elected_idx=i;
            }
        }
        candidates[elected_idx].elected=true;
        //emit
        emit ChairmanResult(candidates[elected_idx].name);
    }

    //2차 투표 함수
    function secondVote(string memory to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.second_voted, "Already voted.");
        bool flag=false;
        for(uint i=0;i<candidates.length;i++){
            if(keccak256(bytes(to))==keccak256(bytes(candidates[i].name)) && !candidates[i].elected){
                flag=true;
                candidates[i].secondVoteCount+=1;
            }
        }
        require(flag, "Not a Candidate");
        sender.second_voted=true;
    }

    //2차 개표 함수
    function secondCountVote() public isOwner{
        uint max_val=0;
        uint elected_idx=0;
        for(uint i=0;i<candidates.length;i++){
            if(max_val<candidates[i].secondVoteCount){
                max_val=candidates[i].secondVoteCount;
                elected_idx=i;
            }
        }
        candidates[elected_idx].elected=true;
        //emit
        emit ViChairmanResult(candidates[elected_idx].name);
    }
}

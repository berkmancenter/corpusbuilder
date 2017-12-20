export default class Version {
    object = null;
    type = 'branch';

    constructor(object, type) {
        this.object = object;
        this.type = type;
    }

    get identifier() {
        if(this.isBranch) {
            return this.object.name;
        }
        else {
            return this.object.id;
        }
    }

    get isBranch() {
        return this.type === 'branch';
    }

    get isRevision() {
        return !this.isBranch;
    }

    get branchName() {
        if(this.type !== 'branch') {
            throw 'Asked for the branch name when the version holds revision';
        }

        return this.object.name;
    }

    get workingVersion() {
        return Version.revision({
            id: this.object.working_id,
            branch: this.object
        });
    }

    get knowsParentBranch() {
        return this.object.branch !== undefined;
    }

    get branchVersion() {
        if(this.isBranch) {
            return this;
        }
        else {
            return Version.branch(this.object.branch);
        }
    }

    get editable() {
        if(this.isBranch) {
            return this.object.editable;
        }
        else {
            if(this.knowsParentBranch) {
                return this.branchVersion.editable;
            }
            else {
                return false;
            }
        }
    }

    update(object) {
        this.object = object;
    }

    static revision(object) {
        if(object === undefined) {
            throw 'Tried to create the version for undefined revision';
        }

        return new this(object, 'revision');
    }

    static branch(object) {
        if(object === undefined) {
            throw 'Tried to create the version for undefined branch';
        }

        if(typeof object === 'string') {
            return new this({
                _partial: true,
                name: object,
            }, 'branch');
        }
        else {
          return new this(object, 'branch');
        }
    }
}

